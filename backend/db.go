package main

import (
	"database/sql"
	"fmt"
	"io"
	"log"
	"strings"

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
	connStr := "host=localhost user=postgres password=8499k8499k port=5433 dbname=cucumberdb sslmode=disable"
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
	var cucumber struct {
		Title       string `json:"title"`
		Description string `json:"description"`
		Price       string `json:"price"`
		PhotoLink   string `json:"photo_link"`
	}

	err := json.NewDecoder(r.Body).Decode(&cucumber)
	if err != nil {
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	query := `INSERT INTO cucumbers (title, description, price, photo_link) VALUES ($1, $2, $3, $4) RETURNING id`
	var id int
	err = db.QueryRow(query, cucumber.Title, cucumber.Description, cucumber.Price, cucumber.PhotoLink).Scan(&id)
	if err != nil {
		http.Error(w, "Failed to insert cucumber", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprintf(w, "Cucumber added with ID: %d", id)
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

	// Декодируем JSON
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	// Получаем токен из заголовка Authorization
	token := r.Header.Get("Authorization")
	if token == "" {
		http.Error(w, "Missing Authorization header", http.StatusUnauthorized)
		return
	}

	// Извлекаем ID пользователя из Supabase
	userID, err := getUserIDFromSupabase(token)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get user ID: %v", err), http.StatusUnauthorized)
		return
	}

	// SQL-запрос для вставки данных в таблицу cart
	query := `INSERT INTO cart (cucumber_id, user_id) VALUES ($1, $2)`
	_, err = db.Exec(query, req.CucumberID, userID)
	if err != nil {
		http.Error(w, "Failed to add to cart", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "Cucumber added to cart")
}
func getUserIDFromSupabase(token string) (int, error) {
	log.Printf("Получен токен: %s\n", token)

	if !strings.Contains(token, ".") {
		log.Println("Invalid token format")
		return 0, fmt.Errorf("invalid JWT format")
	}

	// Запрос к Supabase
	client := &http.Client{}
	req, err := http.NewRequest("GET", "https://<supabase-url>/auth/v1/user", nil)
	if err != nil {
		return 0, fmt.Errorf("failed to create request: %v", err)
	}
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("apikey", "<supabase-anon-key>")

	resp, err := client.Do(req)
	if err != nil {
		return 0, fmt.Errorf("failed to send request: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		log.Printf("Supabase error: %s\n", string(body))
		return 0, fmt.Errorf("Supabase error: %s", string(body))
	}

	var user struct {
		ID int `json:"id"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&user); err != nil {
		return 0, fmt.Errorf("failed to decode response: %v", err)
	}

	log.Printf("User ID: %d\n", user.ID)
	return user.ID, nil
}

func getCart(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query(`SELECT c.id, c.title, c.description, c.price, c.photo_link 
		FROM cucumbers c 
		JOIN cart ct ON c.id = ct.cucumber_id`)
	if err != nil {
		http.Error(w, "Failed to fetch cart", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

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

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(cart)
}

func main() {
	initDB()

	http.HandleFunc("/cucumbers", enableCors(getCucumbers))
	http.HandleFunc("/add", enableCors(addCucumber))
	http.HandleFunc("/addToFavorites", enableCors(addToFavorites))
	http.HandleFunc("/removeFromFavorites", enableCors(removeFromFavorites))
	http.HandleFunc("/getFavorites", enableCors(getFavorites))
	http.HandleFunc("/addToCart", enableCors(addToCart))
	http.HandleFunc("/getCart", enableCors(getCart))
	http.HandleFunc("/register", enableCors(registerHandler))
	http.HandleFunc("/login", enableCors(loginHandler))
	http.HandleFunc("/logout", enableCors(logoutHandler))

	fmt.Println("Server running on port 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
