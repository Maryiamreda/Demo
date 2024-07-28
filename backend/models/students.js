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

            type: mongoose.Schema.Types.ObjectId,
            ref: "address"
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