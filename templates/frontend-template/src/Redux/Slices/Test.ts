import { createSlice, type PayloadAction } from '@reduxjs/toolkit'

type TestState = {
    text: string
}

const initialState: TestState = {
    text: 'default'
}

const Test = createSlice({
    name: 'test',
    initialState,
    reducers: {
        setText(state, action: PayloadAction<string>) {
            state.text = action.payload
        }
    }
});

export const { 
    setText
} = Test.actions;

export default Test.reducer;