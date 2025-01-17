package main

import (
	"database/sql"
	"fmt"
	"io"
	"log"
	"strings"
	"time"

	"encoding/json"
	"net/http"

	_ "github.com/lib/pq"
)

var db *sql.DB

var supabaseURL = "https://xzibhythexmxaquxyrrf.supabase.co"
var supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6aWJoeXRoZXhteGFxdXh5cnJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3MjkwMzUsImV4cCI6MjA1MDMwNTAzNX0.3G1ugfU2rHDco8_e6cjtkn5imz955Z5qR_2MaBDbpGY"

type AuthRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func enableCors(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}

func registerHandler(w http.ResponseWriter, r *http.Request) {
	var req AuthRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	client := &http.Client{}
	request, err := http.NewRequest("POST", supabaseURL+"/auth/v1/signup", strings.NewReader(fmt.Sprintf(
		`{"email":"%s","password":"%s"}`, req.Email, req.Password,
	)))
	if err != nil {
		http.Error(w, "Failed to create request", http.StatusInternalServerError)
		return
	}
	request.Header.Set("apikey", supabaseKey)
	request.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(request)
	if err != nil {
		http.Error(w, "Failed to send request", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(resp.StatusCode)
	json.NewDecoder(resp.Body).Decode(w)
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	var req AuthRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error": "Invalid input"}`, http.StatusBadRequest)
		return
	}

	client := &http.Client{}
	request, err := http.NewRequest("POST", supabaseURL+"/auth/v1/token?grant_type=password", strings.NewReader(fmt.Sprintf(
		`{"email":"%s","password":"%s"}`, req.Email, req.Password,
	)))
	if err != nil {
		http.Error(w, `{"error": "Failed to create request"}`, http.StatusInternalServerError)
		fmt.Println("Error creating request:", err)
		return
	}
	request.Header.Set("apikey", supabaseKey)
	request.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(request)
	if err != nil {
		http.Error(w, `{"error": "Failed to send request"}`, http.StatusInternalServerError)
		fmt.Println("Error sending request:", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		http.Error(w, fmt.Sprintf(`{"error": "Supabase error", "details": %s}`, body), resp.StatusCode)
		return
	}

	var supabaseResponse map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&supabaseResponse); err != nil {
		http.Error(w, `{"error": "Failed to parse Supabase response"}`, http.StatusInternalServerError)
		fmt.Println("Error parsing Supabase response:", err)
		return
	}

	// Успешный ответ
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(supabaseResponse)
}

func logoutHandler(w http.ResponseWriter, r *http.Request) {
	token := r.Header.Get("Authorization")
	if token == "" {
		http.Error(w, `{"error": "Missing Authorization header"}`, http.StatusUnauthorized)
		return
	}

	client := &http.Client{}
	request, err := http.NewRequest("POST", supabaseURL+"/auth/v1/logout", nil)
	if err != nil {
		http.Error(w, `{"error": "Failed to create request"}`, http.StatusInternalServerError)
		return
	}
	request.Header.Set("apikey", supabaseKey)
	request.Header.Set("Authorization", token)

	resp, err := client.Do(request)
	if err != nil {
		http.Error(w, `{"error": "Failed to send request"}`, http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNoContent {
		body, _ := io.ReadAll(resp.Body)
		http.Error(w, fmt.Sprintf(`{"error": "Supabase error: %s"}`, body), resp.StatusCode)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"message": "Logged out successfully"})
}

// Инициализация соединения с базой данных
func initDB() {
	connStr := "host=localhost user=postgres password=8499k8499k port=5432 dbname=cucumberdb sslmode=disable"
	var err error
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatalf("Failed to connect to the database: %v", err)
	}

	err = db.Ping()
	if err != nil {
		log.Fatalf("Failed to ping the database: %v", err)
	}

	fmt.Println("Connected to the database successfully!")
}

func getCucumbers(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query(`SELECT id, title, description, price, photo_link FROM cucumbers`)
	if err != nil {
		http.Error(w, "Failed to fetch cucumbers", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var cucumbers []map[string]interface{}
	for rows.Next() {
		var id int
		var title, description, price, photoLink string

		err := rows.Scan(&id, &title, &description, &price, &photoLink)
		if err != nil {
			http.Error(w, "Failed to scan row", http.StatusInternalServerError)
			return
		}

		cucumbers = append(cucumbers, map[string]interface{}{
			"id":          id,
			"title":       title,
			"description": description,
			"price":       price,
			"photo_link":  photoLink,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(cucumbers)
}

func addCucumber(w http.ResponseWriter, r *http.Request) {
	// Структура для парсинга данных из запроса
	var cucumber struct {
		Title       string `json:"title"`
		Description string `json:"description"`
		Price       string `json:"price"`
		PhotoLink   string `json:"photo_link"`
	}

	// Парсинг тела запроса
	err := json.NewDecoder(r.Body).Decode(&cucumber)
	if err != nil {
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	// Извлечение токена из заголовка Authorization
	token := r.Header.Get("Authorization")
	if token == "" {
		http.Error(w, "Missing Authorization header", http.StatusUnauthorized)
		return
	}

	// Получение user_id из Supabase
	userID, err := getUserIDFromSupabase(token)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get user ID: %v", err), http.StatusUnauthorized)
		return
	}

	// SQL-запрос для вставки данных в таблицу cucumbers
	query := `INSERT INTO cucumbers (title, description, price, photo_link, user_id) VALUES ($1, $2, $3, $4, $5) RETURNING id`
	var id int
	err = db.QueryRow(query, cucumber.Title, cucumber.Description, cucumber.Price, cucumber.PhotoLink, userID).Scan(&id)
	if err != nil {
		http.Error(w, "Failed to insert cucumber", http.StatusInternalServerError)
		return
	}

	// Успешный ответ
	w.WriteHeader(http.StatusCreated)
	fmt.Fprintf(w, `{"id": %d, "message": "Cucumber added successfully"}`, id)
}

func addToFavorites(w http.ResponseWriter, r *http.Request) {
	var req struct {
		ID int `json:"id"`
	}

	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	query := `INSERT INTO favorites (cucumber_id) VALUES ($1)`
	_, err = db.Exec(query, req.ID)
	if err != nil {
		http.Error(w, "Failed to add to favorites", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "Cucumber added to favorites")
}

func removeFromFavorites(w http.ResponseWriter, r *http.Request) {
	var req struct {
		ID int `json:"id"`
	}

	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	query := `DELETE FROM favorites WHERE cucumber_id = $1`
	_, err = db.Exec(query, req.ID)
	if err != nil {
		http.Error(w, "Failed to remove from favorites", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "Cucumber removed from favorites")
}

func getFavorites(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query(`SELECT c.id, c.title, c.description, c.price, c.photo_link
		FROM cucumbers c 
		JOIN favorites f ON c.id = f.cucumber_id`)
	if err != nil {
		http.Error(w, "Failed to fetch favorites", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var favorites []map[string]interface{}
	for rows.Next() {
		var id int
		var title, description, price, photoLink string

		err := rows.Scan(&id, &title, &description, &price, &photoLink)
		if err != nil {
			http.Error(w, "Failed to scan row", http.StatusInternalServerError)
			return
		}

		favorites = append(favorites, map[string]interface{}{
			"id":          id,
			"title":       title,
			"description": description,
			"price":       price,
			"photo_link":  photoLink,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(favorites)
}

func addToCart(w http.ResponseWriter, r *http.Request) {
	var req struct {
		CucumberID int `json:"id"`
	}

	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	token := r.Header.Get("Authorization")
	if token == "" {
		http.Error(w, "Missing Authorization header", http.StatusUnauthorized)
		return
	}

	userID, err := getUserIDFromSupabase(token)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get user ID: %v", err), http.StatusUnauthorized)
		return
	}

	log.Printf("Adding to cart: cucumber_id=%d, user_id=%s", req.CucumberID, userID)

	query := `INSERT INTO cart (cucumber_id, user_id) VALUES ($1, $2)`
	_, err = db.Exec(query, req.CucumberID, userID)
	if err != nil {
		log.Printf("SQL Error: %v", err)
		http.Error(w, "Не получилось добавить в корзину", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "Кукумбер добавлен в корзину")
}

func getUserIDFromSupabase(token string) (string, error) {
	log.Printf("Получен токен: %s\n", token)

	if !strings.HasPrefix(token, "Bearer ") {
		token = "Bearer " + token
	}

	client := &http.Client{}
	req, err := http.NewRequest("GET", "https://xzibhythexmxaquxyrrf.supabase.co/auth/v1/user", nil)
	if err != nil {
		return "", fmt.Errorf("failed to create request: %v", err)
	}
	req.Header.Set("Authorization", token)
	req.Header.Set("apikey", supabaseKey)

	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to send request: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		log.Printf("Supabase error: %s\n", string(body))
		return "", fmt.Errorf("Supabase error: %s", string(body))
	}

	var user struct {
		ID string `json:"id"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&user); err != nil {
		return "", fmt.Errorf("failed to decode response: %v", err)
	}

	log.Printf("User ID: %s\n", user.ID)
	return user.ID, nil
}

func getCart(w http.ResponseWriter, r *http.Request) {
	// Получение токена из заголовка
	token := r.Header.Get("Authorization")
	if token == "" {
		http.Error(w, "Missing Authorization header", http.StatusUnauthorized)
		return
	}

	// Получение user_id на основе токена
	userID, err := getUserIDFromSupabase(token)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get user ID: %v", err), http.StatusUnauthorized)
		return
	}

	// Запрос для получения данных корзины конкретного пользователя
	rows, err := db.Query(`
		SELECT c.id, c.title, c.description, c.price, c.photo_link 
		FROM cucumbers c
		JOIN cart ct ON c.id = ct.cucumber_id
		WHERE ct.user_id = $1
	`, userID)
	if err != nil {
		http.Error(w, "Failed to fetch cart", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Формирование данных корзины
	var cart []map[string]interface{}
	for rows.Next() {
		var id int
		var title, description, price, photoLink string

		err := rows.Scan(&id, &title, &description, &price, &photoLink)
		if err != nil {
			http.Error(w, "Failed to scan row", http.StatusInternalServerError)
			return
		}

		cart = append(cart, map[string]interface{}{
			"id":          id,
			"title":       title,
			"description": description,
			"price":       price,
			"photo_link":  photoLink,
		})
	}

	// Отправка данных в ответ
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(cart)
}

func placeOrder(w http.ResponseWriter, r *http.Request) {
	token := r.Header.Get("Authorization")
	if token == "" {
		http.Error(w, "Missing Authorization header", http.StatusUnauthorized)
		return
	}

	userID, err := getUserIDFromSupabase(token)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get user ID: %v", err), http.StatusUnauthorized)
		return
	}

	// Перенос всех элементов из корзины в таблицу orders с названием
	_, err = db.Exec(`
        INSERT INTO orders (user_id, cucumber_id, cucumber_title)
        SELECT ct.user_id, c.id, c.title
        FROM cart ct
        JOIN cucumbers c ON ct.cucumber_id = c.id
        WHERE ct.user_id = $1
    `, userID)
	if err != nil {
		http.Error(w, "Failed to place order", http.StatusInternalServerError)
		return
	}

	// Очистка корзины
	_, err = db.Exec("DELETE FROM cart WHERE user_id = $1", userID)
	if err != nil {
		http.Error(w, "Failed to clear cart", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "Order placed successfully")
}

func getOrders(w http.ResponseWriter, r *http.Request) {
	token := r.Header.Get("Authorization")
	if token == "" {
		http.Error(w, "Missing Authorization header", http.StatusUnauthorized)
		return
	}

	userID, err := getUserIDFromSupabase(token)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get user ID: %v", err), http.StatusUnauthorized)
		return
	}

	rows, err := db.Query(`
        SELECT id, cucumber_id, cucumber_title, created_at
        FROM orders
        WHERE user_id = $1
        ORDER BY created_at DESC
    `, userID)
	if err != nil {
		http.Error(w, "Failed to fetch orders", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var orders []map[string]interface{}
	for rows.Next() {
		var id, cucumberID int
		var cucumberTitle string
		var createdAt time.Time

		err := rows.Scan(&id, &cucumberID, &cucumberTitle, &createdAt)
		if err != nil {
			http.Error(w, "Failed to scan row", http.StatusInternalServerError)
			return
		}

		orders = append(orders, map[string]interface{}{
			"id":             id,
			"cucumber_id":    cucumberID,
			"cucumber_title": cucumberTitle,
			"created_at":     createdAt,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(orders)
}
func getMessages(w http.ResponseWriter, r *http.Request) {
	chatID := r.URL.Query().Get("chat_id")
	if chatID == "" {
		http.Error(w, "Missing chat_id parameter", http.StatusBadRequest)
		return
	}

	rows, err := db.Query(`
		SELECT id, sender_id, content, created_at
		FROM messages
		WHERE chat_id = $1
	`, chatID)
	if err != nil {
		http.Error(w, "Failed to fetch messages", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var messages []map[string]interface{}
	for rows.Next() {
		var id int
		var senderID, content string
		var createdAt time.Time

		err := rows.Scan(&id, &senderID, &content, &createdAt)
		if err != nil {
			http.Error(w, "Failed to scan row", http.StatusInternalServerError)
			return
		}

		messages = append(messages, map[string]interface{}{
			"id":         id,
			"sender_id":  senderID, // Возвращаем sender_id
			"content":    content,
			"created_at": createdAt,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(messages)
}

func sendMessage(w http.ResponseWriter, r *http.Request) {
	var req struct {
		ChatID  string `json:"chat_id"`
		Content string `json:"content"`
	}

	// Декодируем тело запроса
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Неверный ввод", http.StatusBadRequest)
		return
	}

	// Проверяем, что chat_id и content не пустые
	if req.ChatID == "" || req.Content == "" {
		http.Error(w, "Всё пусто", http.StatusBadRequest)
		return
	}

	// Получаем токен пользователя из заголовка Authorization
	token := r.Header.Get("Authorization")
	if token == "" {
		http.Error(w, "Отсутствует заголовок авторизации", http.StatusUnauthorized)
		return
	}

	// Получаем user_id из токена
	userID, err := getUserIDFromSupabase(token)
	if err != nil {
		http.Error(w, fmt.Sprintf("Ошибка при получении User ID: %v", err), http.StatusUnauthorized)
		return
	}

	// Логируем сообщение
	log.Printf("Юзер %s отправил следующее сообщение в чат: %s", userID, req.Content)

	// Выполняем SQL-запрос для добавления сообщения
	query := `INSERT INTO messages (chat_id, sender_id, content) VALUES ($1, $2, $3)`
	_, err = db.Exec(query, req.ChatID, userID, req.Content)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to send message: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprintf(w, `{"message": "Сообщение успешно отправлено", "content": "%s"}`, req.Content)
}

func messagesHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		getMessages(w, r) // Обработка запроса на получение сообщений
	case http.MethodPost:
		sendMessage(w, r) // Обработка запроса на отправку сообщения
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}
func main() {
	initDB()

	http.HandleFunc("/cucumbers", enableCors(getCucumbers))
	http.HandleFunc("/addCucumber", enableCors(addCucumber))
	http.HandleFunc("/addToFavorites", enableCors(addToFavorites))
	http.HandleFunc("/removeFromFavorites", enableCors(removeFromFavorites))
	http.HandleFunc("/getFavorites", enableCors(getFavorites))
	http.HandleFunc("/addToCart", enableCors(addToCart))
	http.HandleFunc("/getCart", enableCors(getCart))
	http.HandleFunc("/register", enableCors(registerHandler))
	http.HandleFunc("/login", enableCors(loginHandler))
	http.HandleFunc("/logout", enableCors(logoutHandler))
	http.HandleFunc("/placeOrder", enableCors(placeOrder))
	http.HandleFunc("/orders", enableCors(getOrders))
	http.HandleFunc("/messages", enableCors(messagesHandler))

	fmt.Println("Server running on port 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
