defmodule Camunda.Task do
  @moduledoc ~S"""
  Module for working with tasks in Camunda
  """

  @list "/task"

  @doc ~S"""
  POST request for getting a task list

  ## Params

    username :: String.t()
    password :: String.t()
    body :: Map.t()
    options :: Keyword.t()

  ## Returns

    {:ok, List.t()} | {:error, String.t()} | {Atom.t(), Map.t()}

  ## Examples

    iex> Camunda.Task.list("demo", "demo", %{}, [])
    {:ok, []}

  """
  def list(username, password, body \\ %{}, options \\ [])

  def list(username, password, body, options) when (is_map(body) === true) do
    with {:ok, encoded_body} <- Jason.encode(body),
         request_headers <- ApiInstance.get_basic_header(username, password),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(@list, encoded_body, request_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, error} -> {status, error}
      result -> {:error, result}
    end
  end

  def load_variables(task, username, password, params \\ [])

  def load_variables(task, username, password, params) do
    Map.put(task, "variables", Camunda.Task.Variables.list(task, username, password, params))
  end
end
