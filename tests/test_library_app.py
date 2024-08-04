import unittest
import os
import json
from flask import Flask
from app import app, load_data, save_data, DataBase

class LibraryAppTestCase(unittest.TestCase):

    def setUp(self):
        # Set up a test client for the Flask app
        self.app = app.test_client()
        self.app.testing = True

        # Set up test data and a temporary database file
        self.test_data = {
            "books": [
                {"title": "Test Book 1", "author": "Author 1"},
                {"title": "Test Book 2", "author": "Author 2"}
            ],
            "borrowed_books": []
        }
        self.test_db = 'data/test_library.json'
        app.config['DataBase'] = self.test_db

        # Ensure the test database file is created
        with open(self.test_db, 'w') as f:
            json.dump(self.test_data, f, indent=4)

    def tearDown(self):
        # Clean up by removing the test database file
        if os.path.exists(self.test_db):
            os.remove(self.test_db)

    def test_load_data(self):
        data = load_data()
        self.assertEqual(data['books'], self.test_data['books'])

    def test_save_data(self):
        new_data = {"books": [], "borrowed_books": []}
        save_data(new_data)
        with open(self.test_db, 'r') as f:
            data = json.load(f)
        self.assertEqual(data, new_data)

    def test_index_page(self):
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Test Book 1', response.data)
        self.assertIn(b'Test Book 2', response.data)

    def test_add_book(self):
        response = self.app.post('/add_book', data=dict(
            title='New Book', author='New Author'
        ), follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Book added successfully!', response.data)
        data = load_data()
        self.assertEqual(len(data['books']), 3)

    def test_update_book(self):
        response = self.app.post('/update_book/Test Book 1', data=dict(
            title='Updated Book 1', author='Updated Author 1'
        ), follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Book updated successfully!', response.data)
        data = load_data()
        self.assertEqual(data['books'][0]['title'], 'Updated Book 1')

    def test_remove_book(self):
        response = self.app.post('/remove_book', data=dict(
            title='Test Book 1'
        ), follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Book removed successfully!', response.data)
        data = load_data()
        self.assertEqual(len(data['books']), 1)

    def test_search_book(self):
        response = self.app.post('/search_book', data=dict(
            title='Test Book 1'
        ))
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Test Book 1', response.data)

    def test_borrow_book(self):
        response = self.app.post('/borrow_book', data=dict(
            title='Test Book 1', borrower='John Doe'
        ), follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Book borrowed successfully!', response.data)
        data = load_data()
        self.assertEqual(len(data['books']), 1)
        self.assertEqual(len(data['borrowed_books']), 1)

    def test_return_book(self):
        # First, borrow a book
        self.app.post('/borrow_book', data=dict(
            title='Test Book 1', borrower='John Doe'
        ))
        response = self.app.post('/return_book', data=dict(
            title='Test Book 1'
        ), follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Book returned successfully!', response.data)
        data = load_data()
        self.assertEqual(len(data['books']), 2)
        self.assertEqual(len(data['borrowed_books']), 0)

    def test_404_error(self):
        response = self.app.get('/nonexistent_page')
        self.assertEqual(response.status_code, 404)
        self.assertIn(b'404 Error', response.data)

if __name__ == '__main__':
    unittest.main()
