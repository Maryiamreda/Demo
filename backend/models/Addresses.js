const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const addressSchema = new Schema({

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
    ,
    Students: [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Students"
        }
    ]


}, { timestamps: true });
const address = mongoose.model('address', addressSchema);
module.exports = address;