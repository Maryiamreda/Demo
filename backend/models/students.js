const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const studentSchema = new Schema({
    FirstName: {
        type: String,
        required: true,
    },
    LastName: {
        type: String,
        required: true,
    },
    Adress: [
        {

            Country: {
                type: String,
                required: true
            },
            City: {
                type: String,
                required: true
            },
            Street1: {
                type: String,
                required: true
            },
            Street2: {
                type: String,
                required: true
            }

        }

    ]
    ,
    Skills: [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: "skills"
        }
    ]


}, { timestamps: true });
const Students = mongoose.model('Students', studentSchema);
module.exports = Students;