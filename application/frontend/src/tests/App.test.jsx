import React from "react";
import { render, screen, waitFor, fireEvent } from "@testing-library/react";
import App from "../App";
import "@testing-library/jest-dom";

global.fetch = jest.fn();

describe("App Component", () => {
  beforeEach(() => {
    global.fetch.mockClear();
  });

  it("fetches and displays todos on load", async () => {
    const todos = [{ _id: "1", todo: "Sample Todo", status: false }];

    // Mock fetch to return the todos
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve(todos),
    });

    render(<App />);

    // Wait for todos to be displayed
    await waitFor(() => {
      expect(screen.getByText("Sample Todo")).toBeInTheDocument();
    });
  });

  it("allows creating a new todo", async () => {
    const todos = [];
    const newTodo = { _id: "2", todo: "New Todo", status: false };

    // Mock initial fetch
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve(todos),
    });

    // Mock creating a new todo
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve(newTodo),
    });

    render(<App />);

    // Simulate entering a new todo
    const input = screen.getByPlaceholderText("Enter a new todo...");
    fireEvent.change(input, { target: { value: "New Todo" } });

    // Simulate form submission
    const button = screen.getByText("Create Todo");
    fireEvent.click(button);

    // Wait for the new todo to be displayed
    await waitFor(() => {
      expect(screen.getByText("New Todo")).toBeInTheDocument();
    });
  });
});
