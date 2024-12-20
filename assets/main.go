package main

import (
	"encoding/json"
	"net/http"
	"sync"
)

type Cucumber struct {
	ID          int    `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Price       string `json:"price"`
	PhotoLink   string `json:"photo_link"`
}

var (
	cucumbers   []Cucumber
	favorites   []Cucumber
	cart        []Cucumber
	muCucumbers sync.Mutex
	muFavorites sync.Mutex
	muCart      sync.Mutex
)

// Получить список всех огурчиков
func getCucumbers(w http.ResponseWriter, r *http.Request) {
	muCucumbers.Lock()
	defer muCucumbers.Unlock()
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(w).Encode(cucumbers)
}

// Добавить новый огурчик
func addCucumber(w http.ResponseWriter, r *http.Request) {
	var newCucumber Cucumber
	err := json.NewDecoder(r.Body).Decode(&newCucumber)
	if err != nil {
		http.Error(w, "Некорректный ввод", http.StatusBadRequest)
		return
	}
	muCucumbers.Lock()
	defer muCucumbers.Unlock()
	for _, cucumber := range cucumbers {
		if cucumber.ID == newCucumber.ID {
			http.Error(w, "Огурчик с данным ID уже существует", http.StatusConflict)
			return
		}
	}
	cucumbers = append(cucumbers, newCucumber)
	w.WriteHeader(http.StatusCreated)
}

// Добавить огурчик в избранное
func addToFavorites(w http.ResponseWriter, r *http.Request) {
	var id struct {
		ID int `json:"id"`
	}
	err := json.NewDecoder(r.Body).Decode(&id)
	if err != nil {
		http.Error(w, "Неверный ввод", http.StatusBadRequest)
		return
	}
	muFavorites.Lock()
	defer muFavorites.Unlock()
	for _, cucumber := range cucumbers {
		if cucumber.ID == id.ID {
			for _, fav := range favorites {
				if fav.ID == id.ID {
					http.Error(w, "Огурчик уже в избранных", http.StatusConflict)
					return
				}
			}
			favorites = append(favorites, cucumber)
			w.WriteHeader(http.StatusOK)
			return
		}
	}
	http.Error(w, "Огурчик не найден", http.StatusNotFound)
}

// Удалить огурчик из избранного
func removeFromFavorites(w http.ResponseWriter, r *http.Request) {
	var id struct {
		ID int `json:"id"`
	}
	err := json.NewDecoder(r.Body).Decode(&id)
	if err != nil {
		http.Error(w, "Некорректный ввод", http.StatusBadRequest)
		return
	}
	muFavorites.Lock()
	defer muFavorites.Unlock()
	for i, fav := range favorites {
		if fav.ID == id.ID {
			favorites = append(favorites[:i], favorites[i+1:]...)
			w.WriteHeader(http.StatusOK)
			return
		}
	}
	http.Error(w, "Огурчик не найден в избранных", http.StatusNotFound)
}

// Добавить огурчик в корзину
func addToCart(w http.ResponseWriter, r *http.Request) {
	var id struct {
		ID int `json:"id"`
	}
	err := json.NewDecoder(r.Body).Decode(&id)
	if err != nil {
		http.Error(w, "Некорректный ввод", http.StatusBadRequest)
		return
	}
	muCart.Lock()
	defer muCart.Unlock()
	for _, cucumber := range cucumbers {
		if cucumber.ID == id.ID {
			for _, item := range cart {
				if item.ID == id.ID {
					http.Error(w, "Огурчик уже в корзине", http.StatusConflict)
					return
				}
			}
			cart = append(cart, cucumber)
			w.WriteHeader(http.StatusOK)
			return
		}
	}
	http.Error(w, "Огурчик не найден", http.StatusNotFound)
}

// Получить список избранных
func getFavorites(w http.ResponseWriter, r *http.Request) {
	muFavorites.Lock()
	defer muFavorites.Unlock()
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(w).Encode(favorites)
}

// Получить корзину
func getCart(w http.ResponseWriter, r *http.Request) {
	muCart.Lock()
	defer muCart.Unlock()
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(w).Encode(cart)
}

func main() {
	http.HandleFunc("/cucumbers", getCucumbers)
	http.HandleFunc("/add", addCucumber)
	http.HandleFunc("/addToFavorites", addToFavorites)
	http.HandleFunc("/removeFromFavorites", removeFromFavorites)
	http.HandleFunc("/getFavorites", getFavorites)
	http.HandleFunc("/addToCart", addToCart)
	http.HandleFunc("/getCart", getCart)

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}
