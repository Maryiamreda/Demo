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
    Students.findById(id).populate('Adress')
        .populate('Skills')
        .then(result => {
            res.send(result);
            console.log(result);
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
app.post('/students/Create', async (req, res) => {
    console.log('Received body:', req.body);
    const { FirstName, LastName, Skills, Address: addressData } = req.body;

    try {
        // Create new addresses if provided
        const addressIds = await Promise.all(addressData?.map(async (address) => {
            const newAddress = new Address(address);
            const savedAddress = await newAddress.save();
            return savedAddress._id;
        }) || []);
        // Create and save the student
        const student = new Students({
            FirstName,
            LastName,
            Adress: addressIds,
            Skills: Skills || [],
        });

        const savedStudent = await student.save();

        // Update the skills collection
        if (savedStudent.Skills.length > 0) {
            await skills.updateMany(
                { '_id': { $in: savedStudent.Skills } },
                { $push: { Students: savedStudent._id } }
            );
        }

        // Update the addresses collection
        if (savedStudent.Adress.length > 0) {
            await Address.updateMany(
                { '_id': { $in: savedStudent.Address } },
                { $push: { Students: savedStudent._id } }
            );
        }

        res.json(savedStudent);
        console.log(req.body);
        console.log('Received Skills:', Skills);

    } catch (err) {
        console.error(err);
        res.status(400).json({ error: err.message || 'An error occurred while creating the student.' });
    }
});



//EditStudent
app.put('/students/Edit/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { FirstName, LastName, Skills, Adress } = req.body;

        // First, create or update address documents
        const addressPromises = Adress.map(async (addr) => {
            if (addr._id) {
                // If address has an ID, update it
                const updatedAddress = await Address.findByIdAndUpdate(
                    addr._id,
                    {
                        Country: addr.Country,
                        City: addr.City,
                        Street1: addr.Street1,
                        Street2: addr.Street2,
                        $addToSet: { Students: id }
                    },
                    { new: true }
                );
                return updatedAddress._id;
            } else {
                // If no ID, create a new address
                const newAddress = new Address({
                    Country: addr.Country,
                    City: addr.City,
                    Street1: addr.Street1,
                    Street2: addr.Street2,
                    Students: [id]
                });
                const savedAddress = await newAddress.save();
                return savedAddress._id;
            }
        });

        const addressIds = await Promise.all(addressPromises);

        // Now update the student with the new/updated address IDs
        const updatedStudent = await Students.findByIdAndUpdate(id, {
            FirstName,
            LastName,
            Skills,
            Adress: addressIds
        }, { new: true });

        if (!updatedStudent) {
            return res.status(404).json({ message: "Student not found" });
        }

        // Populate the addresses for the response
        await updatedStudent.populate('Adress');

        return res.status(200).json(updatedStudent);
    } catch (error) {
        console.error('Error updating student:', error);
        return res.status(500).json({ message: error.message });
    }
});

// app.put('/students/Edit/:id', async (req, res) => {
//     try {
//         const { id } = req.params;
//         const student = await Students.findByIdAndUpdate(id, req.body)
//         if (!student) {
//             return res.status(404).json({ message: "student not found" })
//         }
//         const updatedstudent = await Students.findById(id)
//         return res.status(200).json(updatedstudent)

//     } catch (error) {
//         return res.status(500).json({ message: error.message })
//     };
// })
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


