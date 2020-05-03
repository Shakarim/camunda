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
  def list(username, password, options \\ [])

  def list(username, password, options) do
    with req_headers <- ApiInstance.get_basic_header(username, password),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(@list, req_headers, options),
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

    {:ok, Map.t()} | {:error, Map.t() | String.t()}

  """
  def load_variables(process_instance, username, password, body \\ %{}, options \\ [])

  def load_variables(%{"id" => process_instance_id} = process_instance, username, password, body, options) do
    with req_body <- Map.merge(body, %{"processInstanceId" => process_instance_id}),
         req_options <- options ++ [params: %{deserializeValues: false}],
         {:ok, variables} <- Camunda.History.VariableInstance.list(username, password, req_body, req_options)
      do
      {:ok, Map.put(process_instance, "variables", variables)}
    else
      result -> result
    end
  end
end
