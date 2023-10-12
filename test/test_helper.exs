Mox.defmock(Fotohaecker.TagDetection.TagDetectionMock,
  for: Fotohaecker.TagDetection.TagDetectionBehaviour
)

Application.put_env(
  :fotohaecker,
  Fotohaecker.TagDetection,
  Fotohaecker.TagDetection.TagDetectionMock
)

Mox.defmock(Fotohaecker.UserManagement.UserManagementMock,
  for: Fotohaecker.UserManagement.UserManagementBehaviour
)

Application.put_env(
  :fotohaecker,
  Fotohaecker.UserManagement,
  Fotohaecker.UserManagement.UserManagementMock
)

# defmodule TestHelperHelpers do
#   @moduledoc false
#   # TODO: these env lists are getting out of hand…
#   def check_and_maybe_add(tests_to_exclude, :auth),
#     do: maybe_add(tests_to_exclude, :auth, "AUTH_0_DOMAIN")

#   def check_and_maybe_add(tests_to_exclude, :payment),
#     do: maybe_add(tests_to_exclude, :payment, "STRIPE_SECRET")

#   defp maybe_add(tests_to_exclude, atom, env) do
#     if System.get_env(env) do
#       tests_to_exclude
#     else
#       # IO.puts("Skipping #{atom} tests because #{env} is not set.")
#       tests_to_exclude ++ [atom]
#     end
#   end
# end

# tests_to_exclude =
#   []
#   |> TestHelperHelpers.check_and_maybe_add(:auth)
#   |> TestHelperHelpers.check_and_maybe_add(:payment)

ExUnit.start(exclude: [])
Ecto.Adapters.SQL.Sandbox.mode(Fotohaecker.Repo, :manual)
