defmodule FriendsApp do
  @moduledoc """
  Documentation for `FriendsApp`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> FriendsApp.hello()
      :world

  """
  def hello do
    :world
  end

  def meu_ambiente do
    case Mix.env() do
      :prod -> "Produção"
      :dev -> "Desenvolvimento"
      :test -> "Teste"
    end
  end
end
