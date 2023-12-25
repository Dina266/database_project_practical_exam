from flask import Flask, request, render_template , redirect , url_for
import pyodbc

# Retrieve the form data and insert it into the database


def customer(cursor, conn, first_name, last_name, state, city, street):
    query =\
        f'''execute customer_inserted '{first_name}', '{last_name}', '{state}',' {city}','{street}' '''

    cursor.execute(query)
    conn.commit()

# Retrieve the search name and perform a search in the database


def search_product(cursor, keyword):
    query =\
        f'''execute search_by_name '{keyword}' '''
    cursor.execute(query)
    results = cursor.fetchall()
    return results


app = Flask(__name__)

# Establish a connection to the SQL Server
DRIVER_NAME = 'SQL Server'
SERVER_NAME = 'WINDOWS10'
conn = pyodbc.connect('Driver={SQL Server};'
                    'Server=WINDOWS10;'
                    'Database=supermarket;'
                    'Trusted_Connection=yes;')

# Create a cursor object to execute SQL queries
cursor = conn.cursor()


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/submit_newProduct', methods=['POST'])
def submit():
    if request.method == 'POST':
        # customer_id = request.form['customer_id']
        first_name = request.form['firstname']
        last_name = request.form['lastname']
        state = request.form['State']
        city = request.form['City']
        street = request.form['Street']

        customer(cursor, conn, first_name, last_name, state, city, street)
        return render_template('index.html')


@app.route('/submit_search', methods=['GET'])
def search():
    if request.method == 'GET':
        keyword = request.args.get('searchName')
        results = search_product(cursor, keyword)
        return render_template('result.html', search_results=results)


# Function to delete a customer by name
def delete_customer_by_name(cursor, name):
    conn.autocommit = False
     
    # Delete records from have_product table related to the customer
    delete_customer_phone_query = '''
        DELETE FROM dbo.customer_phone
        WHERE customer_id IN (SELECT customer_id FROM customer WHERE first_name = ?)
    '''
    cursor.execute(delete_customer_phone_query , (name,))
    
    # Delete records from have_product table related to the customer
    delete_hvp_query = '''
        DELETE FROM dbo.have_product
        WHERE order_id IN (SELECT order_id FROM dbo.orders WHERE customer_id IN (SELECT customer_id FROM dbo.customer WHERE first_name = ?))
    '''
    cursor.execute(delete_hvp_query, (name,))

    # Delete orders related to the customer
    delete_orders_query = '''
        DELETE FROM dbo.orders
        WHERE customer_id IN (SELECT customer_id FROM dbo.customer WHERE first_name = ?)
    '''
    cursor.execute(delete_orders_query, (name,))

    # Delete customer
    delete_customer_query = '''
        DELETE FROM dbo.customer
        WHERE first_name = ?
    ''' 
   
    cursor.execute(delete_customer_query, (name,))
    conn.commit()

    # Reset autocommit to True
    conn.autocommit = True
    return cursor.rowcount > 0



# for link the delete function
@app.route('/submit_delete', methods=['POST'])
def submit_delete():
    if request.method == 'POST':
        delete_customer_name = request.form.get('deleteCustomerName')
        result = delete_customer_by_name(cursor, delete_customer_name)

        if result:
            return render_template('delete_confirmation.html', deleted_customer_name=delete_customer_name)
        else:
            return redirect(url_for('index'))

app.run(debug=True)

# Close the cursor and connection
cursor.close()
conn.close()