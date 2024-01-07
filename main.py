from fastapi import FastAPI, Response

from tts1.kazakh_tts_service import KazakhTtsService

app = FastAPI()


@app.get("/api/text2speech", response_class=Response, response_model=bytes)
async def text2speech(text: str):
    wav_bytes = KazakhTtsService().text2speech_bytes(text)
    # headers = {'Content-Disposition': 'attachment; filename="speach.wav"'}
    headers = {}
    return Response(wav_bytes, headers=headers, media_type='audio/wav')
