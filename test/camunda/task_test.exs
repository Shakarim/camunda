defmodule Camunda.TaskTest do
  use ExUnit.Case

  alias Camunda.Task
  alias Camunda.FnCase

  test "list/4 with valid data" do
    {username, password} = FnCase.get_auth_data()
    {status, result} = Task.list(username, password)

    assert status === :ok
    assert is_list(result) === :true
  end

  test "list/4 with invalid auth data" do
    {status, result} = Task.list("wrong_username", "wrong_password")

    assert status === :unauthorized
    assert is_map(result) === :true
  end
end
