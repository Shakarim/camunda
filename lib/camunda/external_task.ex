defmodule Camunda.ExternalTask do
  @moduledoc ~S"""
  Module for working with external tasks
  """

  @list "/external-task"
  @fetch_and_lock "/external-task/fetchAndLock"
  @complete "/external-task/{id}/complete"

  @doc """
  Returns tuple with list of external tasks

  ## Returns

    {:ok, data::List.t()}

  ## Params

    username :: String.t()
    password :: String.t()

  ## Example

    iex> Nbd.CamundaApi.ExternalTask.list("demo", "demo")
    {:ok, []}

  """
  def list(username, password, options \\ %{})

  def list(username, password, options) do
    with request_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- @list,
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(request_url, request_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.ExternalTask.list/3"}
    end
  end

  @doc """
  Function for fetching and lick external tasks for working with them

  ## Params

    username :: String.t()
    password :: String.t()
    body :: Map.t()
    options :: Keyword.t()

  ## Returns

    {:ok, List.t()}
    {:unauthorized, _}
    {:internal_server_error}

  ## Examples

    iex> Nbd.CamundaApi.ExternalTask.fetch_and_lock("demo", "demo")
    {:ok, []}

  """
  def fetch_and_lock(username, password, body \\ %{}, options \\ [])

  def fetch_and_lock(username, password, body, options) do
    with request_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- @fetch_and_lock,
         {:ok, req_body} <- Jason.encode(body),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(request_url, req_body, request_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.ExternalTask.fetch_and_lock/4"}
    end
  end

  @doc """
  Completes selected external task by external_task_id

  ## Params

    username :: String.t()
    password :: String.t()
    external_task_id :: String.t()
    body :: Map.t()
    options :: Keyword.t()

  ## Returns

    {:ok, %{}}
    {:internal_server_error, _}
    {:not_found, _}

  ## Examples

    iex> Nbd.CamundaApi.ExternalTask.complete("demo", "demo", "some_worker_id")
    {
      :internal_server_error,
      %{
        "message" => "External task with id some_identity does not exist",
        "type" => "RestException"
      }
    }

  """
  def complete(username, password, external_task_id, body \\ %{}, options \\ [])

  def complete(username, password, external_task_id, body, options) do
    with request_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- String.replace(@complete, "{id}", external_task_id),
         {:ok, req_body} <- Jason.encode(body),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(request_url, req_body, request_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.ExternalTask.complete/5"}
    end
  end
end
