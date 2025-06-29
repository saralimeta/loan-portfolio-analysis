import joblib
import pandas as pd
import streamlit as st

# Load the trained model
pipeline = joblib.load('loan_default_model.pkl')

import streamlit as st

st.title("Loan Default Risk Predictor")

# hardocded (temporary)
loan_amount = st.number_input("Loan Amount", value=500000)
term_length = st.slider("Loan Term (days)", 0, 2000, 180)
repeat_borrower = st.selectbox("Repeat Borrower", ['True', 'False']) == 'True'
industry = st.selectbox("Industry", ['retail', 'construction', 'manufacturing', 'commercial & professional services', 'materials'])
company_type = st.selectbox("Company Type", ['single', 'partnership', 'corporation'])
segment = st.selectbox("Segment", ['Segment 1', 'Segment 2', 'Segment 3', 'Segment 4'])
cohort_month = st.selectbox("Cohort Month", ['2023-01', '2023-02', '2023-03', '2020-01', '2019-05'])

if st.button("Predict"):
    # Create input DataFrame
    new_input = pd.DataFrame([{
        'INITIAL_LOAN_AMOUNT': loan_amount,
        'LOAN_TERM_LENGTH': term_length,
        'REPEAT_BORROWER': repeat_borrower,
        'INDUSTRY': industry,
        'COMPANY_TYPE': company_type,
        'SEGMENT': segment,
        'COHORT_MONTH': cohort_month
    }])
    prediction = pipeline.predict(new_input)[0]
    probability = pipeline.predict_proba(new_input)[0][1]
    st.success(f"Default Probability: {probability:.2%}")
    if prediction == 1:
        st.error("⚠️ HIGH RISK of Default")
    else:
        st.info("✅ LOW RISK of Default")
