import React from "react";
import ReactDOM from "react-dom";
import { Draggable } from "@hello-pangea/dnd";

export default function PortalAwareDraggable({ children, ...props }) {
  const portalRoot = document.getElementById("drag-portal-root");

  return (
    <Draggable {...props}>
      {(provided, snapshot) => {
        const child = children(provided, snapshot);
        const element = snapshot.isDragging
          ? ReactDOM.createPortal(child, portalRoot || document.body)
          : child;
        return element;
      }}
    </Draggable>
  );
}
