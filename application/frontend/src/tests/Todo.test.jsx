import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import Todo from "../Todo";
import "@testing-library/jest-dom";

describe("Todo Component", () => {
  const mockSetTodos = jest.fn();

  const sampleTodo = {
    _id: "12345",
    todo: "Write unit tests",
    status: false,
  };

  it("renders the todo text", () => {
    render(<Todo todo={sampleTodo} setTodos={mockSetTodos} />);
    expect(screen.getByText(sampleTodo.todo)).toBeInTheDocument();
  });

  it("renders the correct status button", () => {
    render(<Todo todo={sampleTodo} setTodos={mockSetTodos} />);
    expect(screen.getByText("☐")).toBeInTheDocument(); // Incomplete status
  });

  it("calls updateTodo on status button click", () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve({ acknowledged: true }),
      })
    );

    render(<Todo todo={sampleTodo} setTodos={mockSetTodos} />);
    const statusButton = screen.getByText("☐");
    fireEvent.click(statusButton);

    expect(global.fetch).toHaveBeenCalledWith(`/api/todos/12345`, expect.anything());
  });

  it("calls deleteTodo on delete button click", () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve({ acknowledged: true }),
      })
    );

    render(<Todo todo={sampleTodo} setTodos={mockSetTodos} />);
    const deleteButton = screen.getByText("🗑️");
    fireEvent.click(deleteButton);

    expect(global.fetch).toHaveBeenCalledWith(`/api/todos/12345`, expect.anything());
  });
});
