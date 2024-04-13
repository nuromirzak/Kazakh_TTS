from fastapi import FastAPI, Response
from fastapi.middleware.cors import CORSMiddleware
from tts1.kazakh_tts_service import KazakhTtsService

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

@app.get("/api/text2speech", response_class=Response, response_model=bytes)
async def text2speech(text: str):
    wav_bytes = KazakhTtsService().text2speech_bytes(text)
    # headers = {'Content-Disposition': 'attachment; filename="speach.wav"'}
    headers = {}
    return Response(wav_bytes, headers=headers, media_type='audio/wav')
