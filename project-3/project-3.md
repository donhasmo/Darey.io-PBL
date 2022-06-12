## STEP 1 -BACKEND CONFIGURATION

`sudo apt update`

![apt-update](./images/apt-update.PNG)

`sudo apt upgrade`

![apt-update](./images/apt-upgrade.PNG)

`curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -`

![location-node.js](./images/location-node.js.PNG)

`sudo apt-get install -y nodejs`

![install-node](./images/install-node.js.PNG)

`node -v `

`npm -v `

![verify-node](./images/verify-node.PNG)

`mkdir Todo`

`ls`

`cd Todo`

![Todo](./images/Todo.PNG)

`npm init`

![npm-init](./images/npm-init.PNG)

### -INSTALL EXPRESSJS

`npm install express`

![install-express](./images/install-express.PNG)

`touch index.js`

`npm install dotenv`

![install-dotenv](./images/install-dotenv.PNG)

`vim index.js`

Copy the below file into index.js

(const express = require('express');
require('dotenv').config();

const app = express();

const port = process.env.PORT || 5000;

app.use((req, res, next) => {
res.header("Access-Control-Allow-Origin", "\*");
res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
next();
});

app.use((req, res, next) => {
res.send('Welcome to Express');
});

app.listen(port, () => {
console.log(`Server running on port ${port}`)
});)

`node index.js`

![node-index](./images/node-index.PNG)

Open http://(PublicIP-or-PublicDNS):5000 in your browser

![browser-access](./images/browser-access.PNG)

`mkdir routes`

`cd routes`

`touch api.js`

`vim api.js`

copy and save the below file

(const express = require ('express');
const router = express.Router();

router.get('/todos', (req, res, next) => {

});

router.post('/todos', (req, res, next) => {

});

router.delete('/todos/:id', (req, res, next) => {

})

module.exports = router;)

### MODELS

`npm install mongoose`

![install-mongoose](./images/install-mongoose.PNG)

`mkdir models`

`cd models`

`touch todo.js`
![dir-models](./images/dir-models.PNG)

`vim todo.js`

Copy and save the file below int todo.js

(const mongoose = require('mongoose');
const Schema = mongoose.Schema;

//create schema for todo
const TodoSchema = new Schema({
action: {
type: String,
required: [true, 'The todo text field is required']
}
})

//create model for todo
const Todo = mongoose.model('todo', TodoSchema);

module.exports = Todo;)

` cd routes`

`vim api.js`

`:%d`

Copy and save the file below into api.js

(const express = require ('express');
const router = express.Router();
const Todo = require('../models/todo');

router.get('/todos', (req, res, next) => {

//this will return all the data, exposing only the id and action field to the client
Todo.find({}, 'action')
.then(data => res.json(data))
.catch(next)
});

router.post('/todos', (req, res, next) => {
if(req.body.action){
Todo.create(req.body)
.then(data => res.json(data))
.catch(next)
}else {
res.json({
error: "The input field is empty"
})
}
});

router.delete('/todos/:id', (req, res, next) => {
Todo.findOneAndDelete({"_id": req.params.id})
.then(data => res.json(data))
.catch(next)
})

module.exports = router;)

![update-api](./images/update-api.PNG)

### MONGODB DATABASE

- create MongoDB account
- create database

`index.js`

![node-index](./images/node-index.PNG)

-Testing Backend Code without Frontend using RESTful API

-in Todo folder

`touch .env`

`vi .env`

-Add the connection string to access the database in it, just as below:

(DB = 'mongodb+srv://<username>:<password>@<network-address>/<dbname>?retryWrites=true&w=majority')


`vim index.js`

- delete the present file and paste the below file;

[const express = require('express');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const routes = require('./routes/api');
const path = require('path');
require('dotenv').config();

const app = express();

const port = process.env.PORT || 5000;

//connect to the database
mongoose.connect(process.env.DB, { useNewUrlParser: true, useUnifiedTopology: true })
.then(() => console.log(`Database connected successfully`))
.catch(err => console.log(err));

//since mongoose promise is depreciated, we overide it with node's promise
mongoose.Promise = global.Promise;

app.use((req, res, next) => {
res.header("Access-Control-Allow-Origin", "\*");
res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
next();
});

app.use(bodyParser.json());

app.use('/api', routes);

app.use((err, req, res, next) => {
console.log(err);
next();
});

app.listen(port, () => {
console.log(`Server running on port ${port}`)
});]

`node index.js`

![node.js-connected](./images/node.js-connected.PNG)

-In postman, create, POST, GET and DELETE request using the link below;

http://(PublicIP-or-PublicDNS):5000/api/todos

![post-request](./images/post-request.PNG)
![get-request](./images/get-request.PNG)

## STEP 2 –FRONTEND CREATION
(in Todo folder)

`npx create-react-app client`
![react-install1](./images/react-install1.PNG)
![react-install2](./images/react-install2.PNG)

(outside Todo folder)

`npm install concurrently --save-dev`

`npm install nodemon --save-dev`

`vi package.json` (in Todo folder)

-replace the "scripts" code with the code below;

[("scripts": {
"start": "node index.js",
"start-watch": "nodemon index.js",
"dev": "concurrently \"npm run start-watch\" \"cd client && npm start\""
},]

-add the value key pair below to the package.json file;

["proxy": "http://localhost:5000"]

`run dev`(in Todo folder)

![run-dev](./images/run-dev.PNG)

### Creating your React Components

`cd client/src`

`mkdir components`

`cd components`

`touch Input.js ListTodo.js Todo.js`

`vi Input.js`

Copy and paste the code below in the file;

[import React, { Component } from 'react';
import axios from 'axios';

class Input extends Component {

state = {
action: ""
}

addTodo = () => {
const task = {action: this.state.action}

    if(task.action && task.action.length > 0){
      axios.post('/api/todos', task)
        .then(res => {
          if(res.data){
            this.props.getTodos();
            this.setState({action: ""})
          }
        })
        .catch(err => console.log(err))
    }else {
      console.log('input field required')
    }

}

handleChange = (e) => {
this.setState({
action: e.target.value
})
}

render() {
let { action } = this.state;
return (
<div>
<input type="text" onChange={this.handleChange} value={action} />
<button onClick={this.addTodo}>add todo</button>
</div>
)
}
}

export default Input]

-Go back to client folder

`npm install axios`
![install-axios](./images/install-axios.PNG)

`cd src/components`

`vi ListTodo.js`

-Copy and paste the code below in the file;

[import React from 'react';

const ListTodo = ({ todos, deleteTodo }) => {

return (
<ul>
{
todos &&
todos.length > 0 ?
(
todos.map(todo => {
return (
<li key={todo._id} onClick={() => deleteTodo(todo._id)}>{todo.action}</li>
)
})
)
:
(
<li>No todo(s) left</li>
)
}
</ul>
)
}

export default ListTodo]

`vi Todo.js`

-Copy the code below into the file;

[import React, {Component} from 'react';
import axios from 'axios';

import Input from './Input';
import ListTodo from './ListTodo';

class Todo extends Component {

state = {
todos: []
}

componentDidMount(){
this.getTodos();
}

getTodos = () => {
axios.get('/api/todos')
.then(res => {
if(res.data){
this.setState({
todos: res.data
})
}
})
.catch(err => console.log(err))
}

deleteTodo = (id) => {

    axios.delete(`/api/todos/${id}`)
      .then(res => {
        if(res.data){
          this.getTodos()
        }
      })
      .catch(err => console.log(err))

}

render() {
let { todos } = this.state;

    return(
      <div>
        <h1>My Todo(s)</h1>
        <Input getTodos={this.getTodos}/>
        <ListTodo todos={todos} deleteTodo={this.deleteTodo}/>
      </div>
    )

}
}

export default Todo;]

-Go back to src folder

`vi App.js`

-Delete the logo code and paste the below code;

[import React from 'react';

import Todo from './components/Todo';
import './App.css';

const App = () => {
return (
<div className="App">
<Todo />
</div>
);
}

export default App;]

`vi App.css`

-Copy and paste the below code in the file;

[.App {
text-align: center;
font-size: calc(10px + 2vmin);
width: 60%;
margin-left: auto;
margin-right: auto;
}

input {
height: 40px;
width: 50%;
border: none;
border-bottom: 2px #101113 solid;
background: none;
font-size: 1.5rem;
color: #787a80;
}

input:focus {
outline: none;
}

button {
width: 25%;
height: 45px;
border: none;
margin-left: 10px;
font-size: 25px;
background: #101113;
border-radius: 5px;
color: #787a80;
cursor: pointer;
}

button:focus {
outline: none;
}

ul {
list-style: none;
text-align: left;
padding: 15px;
background: #171a1f;
border-radius: 5px;
}

li {
padding: 15px;
font-size: 1.5rem;
margin-bottom: 15px;
background: #282c34;
border-radius: 5px;
overflow-wrap: break-word;
cursor: pointer;
}

@media only screen and (min-width: 300px) {
.App {
width: 80%;
}

input {
width: 100%
}

button {
width: 100%;
margin-top: 15px;
margin-left: 0;
}
}

@media only screen and (min-width: 640px) {
.App {
width: 60%;
}

input {
width: 50%;
}

button {
width: 30%;
margin-left: 10px;
margin-top: 0;
}
}
Exit

In the src directory open the index.css

vim index.css
Copy and paste the code below:

body {
margin: 0;
padding: 0;
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen",
"Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue",
sans-serif;
-webkit-font-smoothing: antialiased;
-moz-osx-font-smoothing: grayscale;
box-sizing: border-box;
background-color: #282c34;
color: #787a80;
}

code {
font-family: source-code-pro, Menlo, Monaco, Consolas, "Courier New",
monospace;
}]

`npm run dev` (in Todo folder)

-Open the link in any browser
http://ip-address:3000

![react-app](./images/react-app.PNG)






