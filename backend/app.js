const express = require('express');
const mongoose = require('mongoose')
const Students = require('./models/students')
const skills = require('./models/Skills')
const Address = require('./models/Addresses')



// express app
const app = express();
app.use(express.json());

const dburl = 'mongodb+srv://netninja:192837@cluster0.r9zdppo.mongodb.net/students-info';
mongoose.connect(dburl, { useNewUrlParser: true, useUnifiedTopology: true })

    .then(result => app.listen(3000))
    .catch(err => console.log(err));
app.set('view engine', 'ejs');


const cors = require("cors");

app.use(cors());



app.get('/', (req, res) => {
    res.send('it is working')
})
//GetAllStudents
app.get('/students', (req, res) => {
    Students.find()
        .then(result => {
            res.send(result);
        })
        .catch(err => {
            console.log(err);
        });
});

//GetStudentById
app.get('/students/:id', (req, res) => {
    const id = req.params.id;
    Students.findById(id)
        .then(result => {
            res.send(result);
        })
        .catch(err => {
            console.log(err);
        });
})

//GetStudentByName
app.get('/students/:FirstName', (req, res) => {
    const firstname = req.params.FirstName;
    Students.find({ FirstName: firstname })
        .then(result => {
            res.send(result);
        })
        .catch(err => {
            console.log(err);
        });
})

//CreateStudent
app.post('/students/Create', (req, res) => {

    const student = new Students(req.body)
    student.save().then((result) => {
        Address.updateMany({ '_id': student.Adress }, { $push: { Students: student._id } })
        res.json(student)


        // res.redirect('/')
    }).catch(err => {
        console.log(err);
    });


})

//EditStudent
app.put('/students/Edit/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const student = await Students.findByIdAndUpdate(id, req.body)
        if (!student) {
            return res.status(404).json({ message: "student not found" })
        }
        const updatedstudent = await Students.findById(id)
        return res.status(200).json(updatedstudent)

    } catch (error) {
        return res.status(500).json({ message: error.message })
    };
})
//DeleteStudent
app.delete('/students/Delete/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const student = await Students.findByIdAndDelete(id, req.body)
        if (!student) {
            return res.status(404).json({ message: "student not found" })
        }
        return res.status(200).json({ message: "student Deleted" })

    } catch (error) {
        return res.status(500).json({ message: error.message })
    };
})

//for skills

//CreateSkill

//GetStudentsBySkillName
app.get('/students/:Skill', (req, res) => {
    const skill = req.params.Skill;
    Students.find({ Skills: skill })
        .then(result => {
            res.send(result);
        })
        .catch(err => {
            console.log(err);
        });
})


