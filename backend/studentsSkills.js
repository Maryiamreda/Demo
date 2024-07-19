const express = require('express');
const mongoose = require('mongoose')
const skills = require('./models/Skills')
const Students = require('./models/students')

const app = express();
app.use(express.json());
const dburl = 'mongodb+srv://netninja:192837@cluster0.r9zdppo.mongodb.net/students-info';
mongoose.connect(dburl, { useNewUrlParser: true, useUnifiedTopology: true })

    .then(result => app.listen(3000))
    .catch(err => console.log(err));
app.set('view engine', 'ejs');



//CreateSkill
app.post('/CreateSkill', (req, res) => {

    const skill = new skills(req.body)
    skill.save().then((result) => {
        res.json(skill)
        Students.updateMany({ '_id': skill.Students }, { $push: { Skills: skill._id } })

        // res.redirect('/')
    }).catch(err => {
        console.log(err);
    });

})

//GetSkills
app.get('/GetSkills/:Name', (req, res) => {
    const name = req.params.Name;
    skills.find({ Name: name })
        .then(result => {
            res.send(result);
        })
        .catch(err => {
            console.log(err);
        });
})

//EditSkill
app.put('/EditSkill/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const skill = await skills.findByIdAndUpdate(id, req.body)
        if (!skill) {
            return res.status(404).json({ message: "skill not found" })
        }
        const updatedskill = await skills.findById(id)
        return res.status(200).json(updatedskill)

    } catch (error) {
        return res.status(500).json({ message: error.message })
    };
})

//DeleteSkill
app.delete('/DeleteSkill/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const skill = await skills.findByIdAndDelete(id, req.body)
        if (!skill) {
            return res.status(404).json({ message: "Skill not found" })
        }
        return res.status(200).json({ message: "Skill Deleted" })

    } catch (error) {
        return res.status(500).json({ message: error.message })
    };
})