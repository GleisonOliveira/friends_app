defmodule FriendsApp.DB.CSV do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu.Menu
  alias FriendsApp.CLI.Friend.Friend
  alias NimbleCSV.RFC4180, as: Parser

  def perform(option) do
    case option do
      %Menu{id: :create, label: _} -> create()
      %Menu{id: :read, label: _} -> read()
      %Menu{id: :update, label: _} -> update()
      %Menu{id: :delete, label: _} -> delete()
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
      email: prompt_message("Digite o email:"),
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
    |> Enum.map(fn [mail, name, phone] ->
      %Friend{name: name, email: mail, phone: phone}
    end)
  end

  defp delete do
    Shell.cmd("cls")

    prompt_message("Digite o e-mail do contato que deseja excluir.")
    |> search_friend_by_email()
    |> check_friend_found()
    |> confirm_delete()
    |> delete_and_save()
  end

  defp search_friend_by_email(email) do
    get_sctruct_list_from_csv()
    |> Enum.find(:not_found, fn list ->
      list.email == email
    end)
  end

  defp check_friend_found(friend) do
    case friend do
      :not_found ->
        Shell.cmd("cls")
        Shell.error("Amigo não encontrado.")
        Shell.prompt("Presione ENTER para continuar.")
        FriendsApp.CLI.Menu.Choice.starts()

      _ ->
        friend
    end
  end

  defp confirm_delete(friend) do
    Shell.cmd("cls")
    Shell.info("Encontramos.")

    show_friends(friend)

    case Shell.yes?("Deseja confirmar e excluir o amigo?") do
      true -> friend
      false -> :error
    end
  end

  defp delete_and_save(friend) do
    case friend do
      :error ->
        Shell.cmd("cls")
        Shell.info("Ok, amigo não excluido.")
        Shell.prompt("Aperte ENTER para continuar")

      _ -> delete_data(friend)
    end
  end

  defp delete_friends_from_struct_list(list, friend) do
    list
    |> Enum.reject(fn elem -> elem.email == friend.email end)
  end

  defp friend_list_to_csv(list) do
    list
    |> Enum.map(fn item ->
      [item.email, item.name, item.phone]
    end)
  end

  defp update do
    Shell.cmd("cls")
    prompt_message("Digite o e-mail do amigo que deseja atualizar.")
    |> search_friend_by_email()
    |> check_friend_found()
    |> confirm_update()
    |> do_update()

  end

  defp confirm_update(friend) do
    Shell.cmd("cls")
    Shell.info("Encontramos...")

    show_friends(friend)

    case Shell.yes?("Deseja atualizar esse amigo?") do
      true -> friend
      false -> :error
    end
  end

  defp do_update(friend) do
    Shell.cmd("cls")
    Shell.info("Agora você irá digitar os dados atualizados.")

    updated_friend = collect_data()

    delete_data(friend)

    updated_friend
    |> transform_on_wrapped_list()
    |> prepare_to_save_data()
    |> save_file([:append])
  end

  defp delete_data(friend) do
    get_sctruct_list_from_csv()
    |> delete_friends_from_struct_list(friend)
    |> friend_list_to_csv()
    |> prepare_to_save_data()
    |> save_file()
  end
end
