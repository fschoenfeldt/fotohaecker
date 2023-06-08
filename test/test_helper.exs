Mox.defmock(Fotohaecker.TagDetection.TagDetectionMock,
  for: Fotohaecker.TagDetection.TagDetectionBehaviour
)

Application.put_env(
  :fotohaecker,
  Fotohaecker.TagDetection,
  Fotohaecker.TagDetection.TagDetectionMock
)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Fotohaecker.Repo, :manual)
