import Api from "../Api";
import type { TestResponse } from "./Types";

const TestCall = Api.injectEndpoints({
    endpoints: (build) => ({
        getTest: build.query<TestResponse, void>({
            query: () => ({
                url: '/test',
                method: 'GET'
            })
        }),
    })
});

export const {
    useGetTestQuery
} = TestCall;
export default TestCall;
