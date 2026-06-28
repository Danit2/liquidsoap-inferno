settings.init.allow_root.set(true)

settings.log.file.set(false)
settings.log.stdout.set(true)
settings.log.level.set(3)

settings.frame.audio.samplerate.set(48000)
settings.frame.audio.channels.set(2)

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
