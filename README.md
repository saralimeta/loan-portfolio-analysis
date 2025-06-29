# 📊 Loan Portfolio Analysis

A complete end-to-end data analysis and modeling project that explores a financial institution’s loan portfolio to uncover key insights about client behavior, loan performance, and default risk. This project combines data cleaning, SQL analytics, cohort analysis, and a machine learning model to predict loan defaults — wrapped up with an interactive Streamlit app.

---

## 🧠 Project Objectives

- Analyze loan trends and customer behavior using SQL
- Assess default risk by segment, industry, and time
- Build a predictive model to estimate likelihood of default
- Communicate findings through a slide deck and interactive app

---

# 💡 Key Highlights

- 📈 **Loan Growth Analysis**
- 🧮 **Risk Analysis**
- 📊 **Customer Analysis**
- 🤖 **ML Model**: Predict loan default probability using client & loan features
- 🖥️ **Streamlit App**

---

## Project Structure

### `queries.sql`

- Contains all SQL scripts used to answer the key business questions across loan growth, risk, and clients.

### `/model/`

- `app.py`: A **Streamlit app** that lets users input loan attributes and returns a predicted risk of default.
- `loan_default_model.pkl`: The trained machine learning model.

### `/notebook/`

- Contains the Jupyter Notebook showing the entire workflow:
  - `data cleaning.ipynb` - Data cleaning and preparation for analysis and query
  - `predicting risk.ipynb` - Feature engineering and Model training and evaluation

---

## How to Run the Streamlit App

To test the model in action, follow these steps:

1. Install required libraries:
   ```bash
   pip install streamlit pandas scikit-learn joblib
   cd model
   streamlit run app.py
   ```

A browser window will open at http://localhost:8501 where you can test different borrower scenarios and view predicted risk.
