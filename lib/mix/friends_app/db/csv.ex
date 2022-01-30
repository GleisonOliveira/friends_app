defmodule FriendsApp.DB.CSV do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu.Menu
  alias FriendsApp.CLI.Friend.Friend
  alias NimbleCSV.RFC4180, as: Parser

  def perform(option) do
    case option do
      %Menu{id: :create, label: _} -> create()
      %Menu{id: :read, label: _} -> read()
      %Menu{id: :update, label: _} -> Shell.info('>>>> UPDATE <<<<')
      %Menu{id: :delete, label: _} -> Shell.info('>>>> DELETE <<<<')
    end

    FriendsApp.CLI.Menu.Choice.starts()
  end

  defp create do
    collect_data()
    |> transform_on_wrapped_list()
    |> prepare_to_save_data()
    |> save_file([:append])
  end

  defp prepare_to_save_data(data) do
    Parser.dump_to_iodata(data)
  end

  defp transform_on_wrapped_list(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> wrap_in_list()
  end

  defp collect_data do
    Shell.cmd("cls")

    %Friend{
      name: prompt_message("Digite o nome:"),
      mail: prompt_message("Digite o email:"),
      phone: prompt_message("Digite o telefone:")
    }
  end

  defp prompt_message(message) do
    Shell.prompt(message)
    |> String.trim()
  end

  defp wrap_in_list(list) do
    [list]
  end

  defp save_file(data, mode \\ []) do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.write!(data, mode)
  end

  defp read do
    get_sctruct_list_from_csv()
    |> show_friends()
  end

  defp show_friends(friends_list) do
    friends_list
    |> Scribe.console()
  end

  defp get_sctruct_list_from_csv do
    read_csv_file()
    |> parse_csv_file_to_list()
    |> csv_list_to_friend_struct_list()
  end

  defp read_csv_file do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.read!()
  end

  defp parse_csv_file_to_list(file) do
    file
    |> Parser.parse_string(headers: false)
  end

  defp csv_list_to_friend_struct_list(list) do
    list
    |> Enum.map(fn [email, name, phone] ->
      %Friend{name: name, mail: email, phone: phone}
    end)
  end
end
