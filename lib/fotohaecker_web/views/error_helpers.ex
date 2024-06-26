defmodule FotohaeckerWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates a list of error messages from a changeset.

  ## Examples

      iex> changeset = Fotohaecker.ContentFixtures.photo_changeset(%{title: "a title that is too long for the changeset", extension: nil})
      iex> ErrorHelpers.error_messages(changeset)
      %{title: ["should be at most 32 character(s)"], extension: ["can't be blank"]}
  """
  def error_messages(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    form.source.errors
    |> Keyword.get_values(field)
    |> Enum.map(fn error ->
      content_tag(:span, translate_error(error),
        class: "invalid-feedback",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(FotohaeckerWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(FotohaeckerWeb.Gettext, "errors", msg, opts)
    end
  end
end
