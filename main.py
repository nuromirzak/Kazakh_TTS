from fastapi import FastAPI, Response
from fastapi.middleware.cors import CORSMiddleware
from tts1.kazakh_tts_service import KazakhTtsService
import sqlite3

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

conn = sqlite3.connect('tts_cache.db', check_same_thread=False)
cursor = conn.cursor()

cursor.execute('''
    CREATE TABLE IF NOT EXISTS audio_cache (
        text TEXT PRIMARY KEY,
        audio BLOB NOT NULL
    )
''')
conn.commit()


@app.on_event("shutdown")
def shutdown_event():
    conn.close()


@app.get("/api/text2speech", response_class=Response, response_model=bytes)
async def text2speech(text: str):
    if len(text) > 250:
        raise HTTPException(status_code=400, detail="Text length should be less than 250 characters")
    cursor.execute("SELECT audio FROM audio_cache WHERE text = ?", (text,))
    row = cursor.fetchone()

    if row:
        wav_bytes = row[0]
    else:
        # Generate the audio since it's not cached
        try:
            wav_bytes = KazakhTtsService().text2speech_bytes(text)
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

        # Store the generated audio in the database
        cursor.execute("INSERT INTO audio_cache (text, audio) VALUES (?, ?)", (text, wav_bytes))
        conn.commit()

    # Headers can be adjusted if needed (e.g., for download prompts)
    headers = {}
    return Response(wav_bytes, headers=headers, media_type='audio/wav')
