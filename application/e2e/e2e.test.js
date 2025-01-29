const request = require("supertest");

const BASE_URL = "http://todo-app-backend-service:5000/api";

describe("E2E Tests for Todo API", () => {
  it("should create a new todo", async () => {
    const response = await request(BASE_URL)
      .post("/todos")
      .send({ todo: "Test Todo" })
      .expect(201);

    expect(response.body.todo).toBe("Test Todo");
  });

  it("should fetch all todos", async () => {
    const response = await request(BASE_URL).get("/todos").expect(200);
    expect(Array.isArray(response.body)).toBe(true);
  });

  it("should update a todo status", async () => {
    const newTodo = await request(BASE_URL)
      .post("/todos")
      .send({ todo: "Update Test" })
      .expect(201);

    const updatedTodo = await request(BASE_URL)
      .put(`/todos/${newTodo.body._id}`)
      .send({ status: true })
      .expect(200);

    expect(updatedTodo.body.acknowledged).toBe(true);
  });

  it("should delete a todo", async () => {
    const newTodo = await request(BASE_URL)
      .post("/todos")
      .send({ todo: "Delete Test" })
      .expect(201);

    await request(BASE_URL).delete(`/todos/${newTodo.body._id}`).expect(200);
  });
});
