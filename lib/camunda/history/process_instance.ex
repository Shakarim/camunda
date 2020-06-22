defmodule Camunda.History.ProcessInstance do
  @moduledoc ~S"""
  Module for working with history of process instances
  """

  @list "/history/process-instance"

  @doc ~S"""
  Returns list of process instances history

  {:ok, [result]} = Camunda.History.ProcessInstance.list("operator", "operator", [params: %{"processDefinitionKey" => "ktt_kp"}])
  Camunda.History.ProcessInstance.load_variables(result, "operator", "operator")
  """
  def list(username, password, body \\ %{}, options \\ [])

  def list(username, password, body, options) do
    with req_headers <- ApiInstance.get_basic_header(username, password),
         {:ok, req_body} <- Jason.encode(body),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(@list, req_body, req_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.History.ProcessInstance.list/3"}
    end
  end

  @doc ~S"""
  Creates "variable" key in task and load variable map into it

  ## Params

    process_instance :: Map.t()
    username :: String.t()
    password :: String.t()
    body :: Map.t()
    options :: Keyword.t()

  ## Returns

    {:ok, Map.t()} | {:ok, List.t()} | {:error, Map.t() | String.t()}

  """
  def load_variables(process_instance, username, password, body \\ %{}, options \\ [])

  def load_variables(process_instance, username, password, body, options) when (is_list(process_instance)) do
    with data <- Enum.map(process_instance, &(load_variables(&1, username, password, body, options))),
         errors <- Enum.filter(data, fn {status, _} -> status !== :ok end)
      do
      case Enum.count(errors) do
        0 -> {:ok, data |> Enum.map(fn {_, v} -> v end)}
        _ -> Enum.take(errors, 1)
      end
    end
  end

  def load_variables(%{"id" => process_instance_id} = process_instance, username, password, body, options) when (is_map(process_instance)) do
    with req_body <- Map.merge(body, %{"processInstanceId" => process_instance_id}),
         req_options <- options ++ [params: %{deserializeValues: false}],
         {:ok, variables} <- Camunda.History.VariableInstance.list(username, password, req_body, req_options)
      do
      {:ok, Map.put(process_instance, "variables", variables)}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.History.ProcessInstance.load_variables/5"}
    end
  end
end
