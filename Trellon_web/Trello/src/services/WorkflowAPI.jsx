import axiosClient from "./axios/axiosApi";

const BASE = "workflow";

// Get (or initialize) the workflow design for a workspace
export const getWorkflowAPI = (workspaceId) =>
  axiosClient.get(`${BASE}/${workspaceId}`);

// Create a new workflow design for a workspace
export const createWorkflowAPI = (data) =>
  axiosClient.post(`${BASE}`, data);

// Add a board node to a workflow design
export const addWorkflowNodeAPI = (designId, data) =>
  axiosClient.post(`${BASE}/${designId}/nodes`, data);

// Persist the drag-end position of a node
export const updateNodePositionAPI = (nodeId, positionX, positionY) =>
  axiosClient.patch(`${BASE}/nodes/${nodeId}/position`, { positionX, positionY });

// Delete a node (and its connected edges)
export const deleteWorkflowNodeAPI = (nodeId) =>
  axiosClient.delete(`${BASE}/nodes/${nodeId}`);

// Add an edge between two nodes
export const addWorkflowEdgeAPI = (data) =>
  axiosClient.post(`${BASE}/edges`, data);

// Delete an edge
export const deleteWorkflowEdgeAPI = (edgeId) =>
  axiosClient.delete(`${BASE}/edges/${edgeId}`);

// Update edge label, direction, type
export const updateWorkflowEdgeAPI = (edgeId, data) =>
  axiosClient.patch(`${BASE}/edges/${edgeId}`, data);
