defmodule Camunda.History.ProcessInstance do
  @moduledoc ~S"""
  Module for working with history of process instances
  """

  @list "/history/process-instance"

  @doc ~S"""
  Returns list of process instances history
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
    options :: Keyword.t()

  ## Returns

    {:ok, Map.t()} | {:error, Map.t() | String.t()}

  """
  def load_variables(process_instance, username, password, options \\ [])

  def load_variables(%{"id" => process_instance_id} = process_instance, username, password, options) do
    with {:ok, req_body} <- Jason.encode(%{"processInstanceId" => process_instance_id}),
         req_options <- [params: %{deserializeValues: false}],
         {:ok, variables} <- Camunda.History.VariableInstance.list(username, password, req_body, req_options)
      do
      {:ok, Map.put(process_instance, "variables", variables)}
    else
      result -> result
    end
  end
end
