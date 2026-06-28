set("log.file", false)
set("log.stdout", true)
set("log.level", 3)

set("frame.audio.samplerate", 48000)
set("frame.audio.channels", 2)

url = getenv("STREAM_URL")

s = input.http(url)

s = audio_to_stereo(s)

s = mksafe(s)

output.alsa(
  id = "inferno_out",
  device = "inferno",
  bufferize = true,
  s
)
