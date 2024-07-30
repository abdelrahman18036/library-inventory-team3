from flask import Flask, render_template, request, redirect, url_for, flash, abort
import json
import os

app = Flask(__name__)
app.secret_key = "dasdasdgajksdgahskjdgasdgkahkas"

DataBase = 'data/library.json'

def load_data():
    if not os.path.exists(DataBase):
        return {"books": [], "borrowed_books": []}
    with open(DataBase, 'r') as f:
        return json.load(f)

def save_data(data):
    with open(DataBase, 'w') as f:
        json.dump(data, f, indent=4)

@app.route('/')
def index():
    data = load_data()
    return render_template('index.html', books=data['books'], borrowed_books=data['borrowed_books'])

@app.route('/add_book', methods=['GET', 'POST'])
def add_book():
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
def update_book(title):
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
def remove_book():
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
def search_book():
    if request.method == 'POST':
        title = request.form['title']
        if not title:
            flash('Search title is required!')
            return redirect(url_for('search_book'))
        data = load_data()
        books = [book for book in data['books'] if title.lower() in book['title'].lower()]
        if not books:
            flash('No books found!')
        return render_template('search_book.html', books=books, search=True)
    return render_template('search_book.html', books=[], search=False)

@app.route('/borrow_book', methods=['GET', 'POST'])
def borrow_book():
    if request.method == 'POST':
        title = request.form['title']
        borrower = request.form['borrower']
        if not title or not borrower:
            flash('Title and borrower are required!')
            return redirect(url_for('borrow_book'))
        data = load_data()
        book = next((book for book in data['books'] if book['title'] == title), None)
        if not book:
            abort(404, description="Book not found")
        data['books'].remove(book)
        data['borrowed_books'].append({"title": title, "borrower": borrower})
        save_data(data)
        flash('Book borrowed successfully!')
        return redirect(url_for('index'))
    return render_template('borrow_book.html')

@app.route('/return_book', methods=['GET', 'POST'])
def return_book():
    if request.method == 'POST':
        title = request.form['title']
        if not title:
            flash('Title is required!')
            return redirect(url_for('return_book'))
        data = load_data()
        borrowed_book = next((book for book in data['borrowed_books'] if book['title'] == title), None)
        if not borrowed_book:
            abort(404, description="Borrowed book not found")
        data['borrowed_books'].remove(borrowed_book)
        data['books'].append({"title": title, "author": borrowed_book.get('author', 'Unknown')})
        save_data(data)
        flash('Book returned successfully!')
        return redirect(url_for('index'))
    return render_template('return_book.html')

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html', error=e), 404

@app.errorhandler(400)
def bad_request(e):
    return render_template('400.html', error=e), 400
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)

