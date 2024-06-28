const express = require('express');
const mongoose = require('mongoose')
const Address = require('./models/Addresses')
const app = express();
app.use(express.json());
const dburl = 'mongodb+srv://netninja:192837@cluster0.r9zdppo.mongodb.net/students-info';
mongoose.connect(dburl, { useNewUrlParser: true, useUnifiedTopology: true })

    .then(result => app.listen(3000))
    .catch(err => console.log(err));
app.set('view engine', 'ejs');




//CreateAddress
app.post('/CreateAddress', (req, res) => {

    const adress = new Address(req.body)
    adress.save().then((result) => {
        res.json(adress)
        // res.redirect('/')
    }).catch(err => {
        console.log(err);
    });

})

//DeleteAddress
app.delete('/DeleteAddress/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const address = await Address.findByIdAndDelete(id, req.body)
        if (!address) {
            return res.status(404).json({ message: "Adress not found" })
        }
        return res.status(200).json({ message: "Adress Deleted" })

    } catch (error) {
        return res.status(500).json({ message: error.message })
    };
})

//EditAddress
app.put('/EditAddress/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const address = await Address.findByIdAndUpdate(id, req.body)
        if (!address) {
            return res.status(404).json({ message: "Adress not found" })
        }
        const updatedAdress = await Adress.findById(id)
        return res.status(200).json(updatedAdress)

    } catch (error) {
        return res.status(500).json({ message: error.message })
    };
})