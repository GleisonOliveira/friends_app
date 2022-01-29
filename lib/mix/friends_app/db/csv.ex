defmodule FriendsApp.DB.CSV do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu.Menu
  alias FriendsApp.CLI.Friend
  alias NimbleCSV.RFC4180, as: Parser

  def perform(option) do
    case option do
      %Menu{id: :create, label: _} -> create()
      %Menu{id: :read, label: _} -> Shell.info('>>>> READ <<<<')
      %Menu{id: :update, label: _} -> Shell.info('>>>> UPDATE <<<<')
      %Menu{id: :delete, label: _} -> Shell.info('>>>> DELETE <<<<')
    end

    FriendsApp.CLI.Menu.Choice.starts()
  end

  defp create do
    collect_data()
    |> Map.values()
    |> wrap_in_list()
    |> Parser.dump_to_iodata()
    |> save_file()
  end

  defp collect_data do
    Shell.cmd("cls")

    %{
      name: prompt_message("Digite o nome:"),
      mail: prompt_message("Digite o email:"),
      phone: prompt_message("Digite o telefone:"),
    }
  end

  defp prompt_message(message) do
   Shell.prompt(message)
   |> String.trim()
  end

  defp wrap_in_list(list) do
    [list]
  end

  defp save_file(data) do
    File.write!("#{File.cwd!}/friends.csv", data, [:append])
  end
end
