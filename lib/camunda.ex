defmodule Camunda do
  @moduledoc ~S"""
  Documentation for Camunda.
  """
  @tasks "/task"
  @task "/task/{id}"
  @task_submit "/task/{id}/submit-form"
  @task_claim "/task/{id}/claim"

  @doc """
  Returns Basic Auth data from conn

  ## Returns

    {:ok, {username, password}}

    {:error, "Auth data not found"}

  ## Params

    %Plug.Conn{}

  """
  def get_basic_auth_data(conn) do
    with [token] <- Plug.Conn.get_req_header(conn, "authorization"),
         [username, password] <- token
                                 |> String.split(" ")
                                 |> List.last()
                                 |> Base.decode64!()
                                 |> String.split(":") do
      {:ok, {username, password}}
    else
      _ -> {:error, "Auth data not found"}
    end
  end

  @doc """
  Returns auth data from app configurations

  ## Returns

    {username :: String.t(), password :: String.t()}
    {nil, nil}

  """
  def get_auth_data,
      do: prepare_auth_data({Application.get_env(:camunda, :username), Application.get_env(:camunda, :password)})


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
  def get_tasks(username, password, body \\ %{}, options \\ [])

  def get_tasks(username, password, body, options) when (is_map(body) === true) do
    with {:ok, encoded_body} <- Jason.encode(body),
         request_headers <- ApiInstance.get_basic_header(username, password),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(@tasks, encoded_body, request_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, error} -> {status, error}
      result -> {:error, result}
    end
  end

  @doc ~S"""
  Creates "variable" key in task and load variable map into it

  ## Params

    task :: Map.t()
    username :: String.t()
    password :: String.t()
    options :: Keyword.t()

  ## Returns

    {:ok, Map.t()} | {:error, Map.t() | String.t()}

  """
  def load_variables(task, username, password, options \\ [params: %{deserializeValues: false}])

  def load_variables(task, username, password, options) when (is_map(task)) do
    with {:ok, variables} <- Camunda.Task.Variables.list(task, username, password, options) do
      {:ok, Map.put(task, "variables", variables)}
    else
      result -> result
    end
  end

  def load_variables(tasks, username, password, options) when (is_list(tasks)) do
    Enum.map(
      tasks,
      fn x ->
        with {:ok, v} <- Camunda.Task.load_variables(x, username, password) do
          v
        else
          _ -> x
        end
      end
    )
  end

  @doc ~S"""
  Claims task by user `username`

  ## Params

    task :: Map.t()
    username :: String.t()
    password :: String.t()
    body :: Map.t()
    options :: Keyword.t()

  ## Returns

    {Atom.t(), Map.t() | List.t() | String.t()}

  """
  def claim(task, username, password, body \\ %{}, options \\ [])

  def claim(%{"id" => id} = _task, username, password, body, options) do
    with request_body <- Map.merge(%{userId: username}, body),
         {:ok, req_body} <- Jason.encode(request_body),
         req_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- String.replace(@task_claim, "{id}", id),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(request_url, req_body, req_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response) do
      {:ok, result}
    else
      {status, error} -> {status, error}
      result -> {:error, result}
    end
  end

  @doc ~S"""
  Returns task by id (this function returns task map only, it's not load variables
  or something else)

  ## Examples

    iex> Nbd.CamundaApi.Task.get(123, "demo", "demo")
    {:error, %{data: String.t()}}

  """
  def get_by_id(task_id, username, password, options \\ [])

  def get_by_id(task_id, username, password, options) do
    with req_headers <- ApiInstance.get_basic_header(username, password),
         req_url <- String.replace(@task, "{id}", task_id),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(req_url, req_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.Task.get_by_id/3"}
    end
  end

  @doc """
  Submit task by route by task id
  """
  def submit(task, username, password, body \\ %{}, options \\ [])

  def submit(%{"id" => task_id} = _task, username, password, body, options) do
    with req_headers <- ApiInstance.get_basic_header(username, password),
         req_url <- String.replace(@task_submit, "{id}", task_id),
         {:ok, req_body} <- Jason.encode(body),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(req_url, req_body, req_headers, options),
         {:no_content, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.Task.get_by_id/3"}
    end
  end

  defp prepare_auth_data({username, password}) when (username !== nil and password !== nil),
       do: {:ok, {username, password}}

  defp prepare_auth_data(_),
       do: {:error, "Server doesn't have configured auth data for camunda. Contact administrator"}
end
