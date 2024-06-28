const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const skillSchema = new Schema({
    Name: {
        type: String,
        required: true,
    },
    Students: [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Students"
        }
    ]


}, { timestamps: true });
const skills = mongoose.model('skills', skillSchema);
module.exports = skills;