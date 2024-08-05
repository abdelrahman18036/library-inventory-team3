from flask import Flask, render_template, request, redirect, url_for, flash, abort
import json
import os
from prometheus_client import Counter, generate_latest, Summary, Gauge, CollectorRegistry
from prometheus_client import multiprocess, start_http_server
from prometheus_client.core import CollectorRegistry

app = Flask(__name__)
app.secret_key = "dasdasdgajksdgahskjdgasdgkahkas"

DataBase = 'data/library.json'

# Prometheus metrics setup
registry = CollectorRegistry()

# Example metrics
REQUEST_COUNT = Counter('request_count', 'App Request Count', ['method', 'endpoint'], registry=registry)
REQUEST_LATENCY = Summary('request_latency_seconds', 'Request latency', ['method', 'endpoint'], registry=registry)
IN_PROGRESS = Gauge('in_progress_requests', 'In progress requests', ['endpoint'], registry=registry)

def load_data():
    """Load the database file and return its content. If file doesn't exist, return default data."""
    if not os.path.exists(DataBase):
        return {"books": [], "borrowed_books": []}
    with open(DataBase, 'r') as f:
        return json.load(f)

def save_data(data):
    """Save the provided data to the database file."""
    with open(DataBase, 'w') as f:
        json.dump(data, f, indent=4)

@app.route('/')
@REQUEST_COUNT.labels(method='GET', endpoint='/').inc()
@REQUEST_LATENCY.labels(method='GET', endpoint='/').time()
@IN_PROGRESS.labels(endpoint='/').track_inprogress()
def index():
    """Render the home page with lists of books and borrowed books."""
    data = load_data()
    return render_template(
        'index.html', 
        books=data['books'], 
        borrowed_books=data['borrowed_books']
    )

@app.route('/metrics')
def metrics():
    """Expose Prometheus metrics."""
    return generate_latest(registry)

@app.route('/add_book', methods=['GET', 'POST'])
@REQUEST_COUNT.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/add_book').inc()
@REQUEST_LATENCY.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/add_book').time()
@IN_PROGRESS.labels(endpoint='/add_book').track_inprogress()
def add_book():
    """Handle the addition of new books."""
    if request.method == 'POST':
        title = request.form['title']
        author = request.form['author']
        if not title or not author:
            flash('Title and author are required!')
            return redirect(url_for('add_book'))
        data = load_data()
        data['books'].append({"title": title, "author": author})
        save_data(data)
        flash('Book added successfully!')
        return redirect(url_for('index'))
    return render_template('add_book.html')

@app.route('/update_book/<title>', methods=['GET', 'POST'])
@REQUEST_COUNT.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/update_book/<title>').inc()
@REQUEST_LATENCY.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/update_book/<title>').time()
@IN_PROGRESS.labels(endpoint='/update_book/<title>').track_inprogress()
def update_book(title):
    """Handle the update of book details."""
    data = load_data()
    book = next((book for book in data['books'] if book['title'] == title), None)
    if not book:
        abort(404, description="Book not found")
    if request.method == 'POST':
        new_title = request.form['title']
        new_author = request.form['author']
        if not new_title or not new_author:
            flash('Title and author are required!')
            return redirect(url_for('update_book', title=title))
        book['title'] = new_title
        book['author'] = new_author
        save_data(data)
        flash('Book updated successfully!')
        return redirect(url_for('index'))
    return render_template('update_book.html', book=book)

@app.route('/remove_book', methods=['GET', 'POST'])
@REQUEST_COUNT.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/remove_book').inc()
@REQUEST_LATENCY.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/remove_book').time()
@IN_PROGRESS.labels(endpoint='/remove_book').track_inprogress()
def remove_book():
    """Handle the removal of books."""
    if request.method == 'POST':
        title = request.form['title']
        data = load_data()
        book = next((book for book in data['books'] if book['title'] == title), None)
        if not book:
            abort(404, description="Book not found")
        data['books'].remove(book)
        save_data(data)
        flash('Book removed successfully!')
        return redirect(url_for('index'))
    return render_template('remove_book.html')

@app.route('/search_book', methods=['GET', 'POST'])
@REQUEST_COUNT.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/search_book').inc()
@REQUEST_LATENCY.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/search_book').time()
@IN_PROGRESS.labels(endpoint='/search_book').track_inprogress()
def search_book():
    """Handle searching for books by title."""
    if request.method == 'POST':
        title = request.form['title']
        if not title:
            flash('Search title is required!')
            return redirect(url_for('search_book'))
        data = load_data()
        books = [
            book for book in data['books'] 
            if title.lower() in book['title'].lower()
        ]
        if not books:
            flash('No books found!')
        return render_template('search_book.html', books=books, search=True)
    return render_template('search_book.html', books=[], search=False)

@app.route('/borrow_book', methods=['GET', 'POST'])
@REQUEST_COUNT.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/borrow_book').inc()
@REQUEST_LATENCY.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/borrow_book').time()
@IN_PROGRESS.labels(endpoint='/borrow_book').track_inprogress()
def borrow_book():
    """Handle borrowing books."""
    data = load_data()
    
    if request.method == 'POST':
        title = request.form['title']
        borrower = request.form['borrower']
        if not title or not borrower:
            flash('Title and borrower are required!')
            return redirect(url_for('borrow_book'))
        
        book = next((book for book in data['books'] if book['title'] == title), None)
        if not book:
            abort(404, description="Book not found")
        
        data['books'].remove(book)
        data['borrowed_books'].append({
            "title": title, 
            "author": book['author'], 
            "borrower": borrower
        })
        save_data(data)
        flash('Book borrowed successfully!')
        return redirect(url_for('index'))
    
    available_books = [book for book in data['books']]
    return render_template('borrow_book.html', books=available_books)

@app.route('/return_book', methods=['GET', 'POST'])
@REQUEST_COUNT.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/return_book').inc()
@REQUEST_LATENCY.labels(method='POST' if request.method == 'POST' else 'GET', endpoint='/return_book').time()
@IN_PROGRESS.labels(endpoint='/return_book').track_inprogress()
def return_book():
    """Handle returning borrowed books."""
    data = load_data()
    borrowed_books = [book for book in data['borrowed_books']]
    
    if request.method == 'POST':
        title = request.form['title']
        if not title:
            flash('Title is required!')
            return redirect(url_for('return_book'))
        
        borrowed_book = next((book for book in borrowed_books 
                              if book['title'] == title), None)
        if not borrowed_book:
            abort(404, description="Borrowed book not found")
        
        data['borrowed_books'].remove(borrowed_book)
        data['books'].append({
            "title": title, 
            "author": borrowed_book['author']
        })
        save_data(data)
        flash('Book returned successfully!')
        return redirect(url_for('index'))
    
    return render_template('return_book.html', borrowed_books=borrowed_books)

@app.errorhandler(404)
def page_not_found(e):
    """Handle 404 errors."""
    return render_template('404.html', error=e), 404

@app.errorhandler(400)
def bad_request(e):
    """Handle 400 errors."""
    return render_template('400.html', error=e), 400

if __name__ == "__main__":
    # Start Prometheus metrics server
    start_http_server(8000)
    app.run(host="0.0.0.0", port=5000, debug=False)
