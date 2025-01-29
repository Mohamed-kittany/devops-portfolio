

export default function Todo(props) {
    const { todo, setTodos } = props;

    const updateTodo = async (todoId, currentStatus) => {
        const updatedStatus = !currentStatus; // Toggle status
        console.log("Updating Todo:", todoId, "to status:", updatedStatus);
    
        const res = await fetch(`/api/todos/${todoId}`, {
            method: "PUT",
            body: JSON.stringify({ status: updatedStatus }),
            headers: {
                "Content-Type": "application/json"
            },
        });
    
        const json = await res.json();
        console.log("Response:", json);
    
        if (json.acknowledged) {
            setTodos(currentTodos => {
                return currentTodos.map((currentTodo) => {
                    if (currentTodo._id === todoId) {
                        return { ...currentTodo, status: updatedStatus };
                    }
                    return currentTodo;
                });
            });
        }
    };
    

    const deleteTodo = async (todoId) => {
        const res = await fetch(`/api/todos/${todoId}`, {
            method: "DELETE"
        });
        const json = await res.json();
        if (json.acknowledged) {
            setTodos(currentTodos => {
                return currentTodos
                .filter((currentTodo) => (currentTodo._id !== todoId));
            })
        }
    };

    return (
        <div className="todo">
            <p>{todo.todo}</p>
            <div className="mutations">
                <button
                    className="todo__status"
                    onClick={() => updateTodo(todo._id, todo.status)}
                >
                    {(todo.status) ? "☑" : "☐"}
                </button>
                <button
                    className="todo__delete"
                    onClick={() => deleteTodo(todo._id)}
                >
                    🗑️
                </button>
            </div>
        </div>
    )
}