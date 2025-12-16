from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
import requests
import json

app = FastAPI(title="Chatbot API (Ollama)")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # à restreindre en prod
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Config Ollama (modèle local Gemma)
OLLAMA_URL = "http://localhost:11434/api/chat"
OLLAMA_MODEL = "mistral"  # adapte si tu utilises un autre tag (ex: "gemma2:9b")
SYSTEM_PROMPT = (
    "Assistant IA de l'aéroport de Lomé. "
    "Aide passagers et personnel. "
    "Réponds en français, bref et clair."
)


class ChatRequest(BaseModel):
    message: str


@app.post("/chat")
async def chat(payload: ChatRequest):
    user_text = payload.message.strip()

    if not user_text:
        raise HTTPException(status_code=400, detail="Message vide")

    # Appel au modèle local via Ollama (mode non-stream pour compatibilité front actuel)
    try:
        resp = requests.post(
            OLLAMA_URL,
            json={
                "model": OLLAMA_MODEL,
                "messages": [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": user_text},
                ],
                "stream": False,
            },
            timeout=60,
        )
    except requests.RequestException as e:
        raise HTTPException(
            status_code=500,
            detail=f"Impossible de contacter le serveur Ollama : {e}",
        )

    if resp.status_code != 200:
        raise HTTPException(
            status_code=500,
            detail=f"Erreur côté Ollama ({resp.status_code}) : {resp.text}",
        )

    data = resp.json()
    bot_response = data.get("message", {}).get("content") or "Aucune réponse générée."

    return {
        "transcription": user_text,
        "response": bot_response,
    }


def stream_ollama_chat(prompt: str):
    """
    Générateur qui proxy le streaming Ollama -> chunks de texte brut.
    """
    try:
        with requests.post(
            OLLAMA_URL,
            json={
                "model": OLLAMA_MODEL,
                "messages": [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": prompt},
                ],
                "stream": True,
            },
            stream=True,
            timeout=0,  # pas de timeout côté client, c'est le serveur qui gère
        ) as resp:
            if resp.status_code != 200:
                # On renvoie une erreur lisible côté client
                yield f"[Erreur Ollama {resp.status_code}] {resp.text}"
                return

            full_text = ""
            for line in resp.iter_lines(decode_unicode=True):
                if not line:
                    continue
                try:
                    data = json.loads(line)
                except json.JSONDecodeError:
                    continue

                delta = (
                    data.get("message", {})
                    .get("content", "")
                )
                if delta:
                    full_text += delta
                    # on envoie le delta directement pour affichage progressif
                    yield delta

    except requests.RequestException as e:
        yield f"[Erreur de connexion à Ollama] {e}"


@app.post("/chat-stream")
async def chat_stream(payload: ChatRequest):
    """
    Endpoint de streaming : renvoie du texte brut chunké.
    À consommer côté front avec fetch + reader (ReadableStream).
    """
    user_text = payload.message.strip()

    if not user_text:
        raise HTTPException(status_code=400, detail="Message vide")

    return StreamingResponse(
        stream_ollama_chat(user_text),
        media_type="text/plain; charset=utf-8",
    )