package main

import (
	"database/sql"
	"fmt"
	"log"

	"encoding/json"
	"net/http"

	_ "github.com/lib/pq"
)

var db *sql.DB

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

	// SQL-запрос для вставки данных в таблицу cart
	query := `INSERT INTO cart (cucumber_id) VALUES ($1)`
	_, err = db.Exec(query, req.CucumberID)
	if err != nil {
		http.Error(w, "Failed to add to cart", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "Cucumber added to cart")
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

	http.HandleFunc("/cucumbers", getCucumbers)
	http.HandleFunc("/add", addCucumber)
	http.HandleFunc("/addToFavorites", addToFavorites)
	http.HandleFunc("/removeFromFavorites", removeFromFavorites)
	http.HandleFunc("/getFavorites", getFavorites)
	http.HandleFunc("/addToCart", addToCart)
	http.HandleFunc("/getCart", getCart)

	fmt.Println("Server running on port 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
