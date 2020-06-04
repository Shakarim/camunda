defmodule Camunda.Task do
  @moduledoc ~S"""
  Module for working with tasks in Camunda
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :string
    field :name, :string
    field :assignee, :string
    field :created, :string
    field :due, :string
    field :followUp, :string
    field :delegationState, :string
    field :description, :string
    field :executionId, :string
    field :owner, :string
    field :parentTaskId, :string
    field :priority, :integer
    field :processDefinitionId, :string
    field :processInstanceId, :string
    field :caseExecutionId, :string
    field :caseDefinitionId, :string
    field :caseInstanceId, :string
    field :taskDefinitionKey, :string
    field :suspended, :boolean
    field :formKey, :string
    field :tenantId, :string
  end

  def changeset(changeset, attrs \\ %{}) do
    changeset
    |> cast(
         attrs,
         [
           :id,
           :name,
           :assignee,
           :created,
           :due,
           :followUp,
           :delegationState,
           :description,
           :executionId,
           :owner,
           :parentTaskId,
           :priority,
           :processDefinitionId,
           :processInstanceId,
           :caseExecutionId,
           :caseDefinitionId,
           :caseInstanceId,
           :taskDefinitionKey,
           :suspended,
           :formKey,
           :tenantId
         ]
       )
    |> validate_required(
         [
           :id,
           :name,
           :assignee,
           :created,
           :due,
           :followUp,
           :delegationState,
           :description,
           :executionId,
           :owner,
           :parentTaskId,
           :priority,
           :processDefinitionId,
           :processInstanceId,
           :caseExecutionId,
           :caseDefinitionId,
           :caseInstanceId,
           :taskDefinitionKey,
           :suspended,
           :formKey,
           :tenantId
         ]
       )
  end
end
