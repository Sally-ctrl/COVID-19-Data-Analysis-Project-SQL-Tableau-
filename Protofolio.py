from unittest.mock import inplace

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import matplotlib
plt.style.use('ggplot')
from matplotlib.pyplot import figure

matplotlib.rcParams['figure.figsize'] = (12,8)
pd.options.mode.chained_assignment = None

pd.set_option('display.max_columns', None)
pd.set_option('display.width', None)

df = pd.read_csv(r'C:\Users\sarah\OneDrive\Desktop\Protofolio project\movies.csv\movies.csv')
#print(df)

for col in df.columns :
    pct_missing=np.mean(df[col].isnull())
    print(f'{col} - {pct_missing:.2%}')

print(df.dtypes)
#data cleaning
df['budget'] = df['budget'].fillna(0).astype('int64')
df['gross'] = df['gross'].fillna(0).astype('int64')
df['budget']=df['budget'].astype('int64')
df['gross']=df['gross'].astype('int64')
print(df)

df['year_correct']=df['released'].astype(str).str[:4]
df=df.sort_values(by=['gross'],inplace=False,ascending=False)

#dropping duplicates
print(df['company'].drop_duplicates().sort_values(ascending=False))
df=df.drop_duplicates()
print(df)

plt.scatter(x=df['budget'], y=df['gross'], edgecolor='black', alpha=0.6)
plt.title('Budget vs Gross Revenue for Films')
plt.xlabel('Gross Budget (in billions/hundreds of millions)')
plt.ylabel('Gross Revenue')
plt.show()

sns.regplot(x='budget', y='gross', data=df,
            scatter_kws={'color': 'red'},
            line_kws={'color': 'blue'})
plt.show()

print(df.corr())

correlation_matrix = df.corr()

sns.heatmap(correlation_matrix, annot = True)
plt.title("Correlation matrix for Numeric Features")
plt.xlabel("Movie features")
plt.ylabel("Movie features")
plt.show()

# non numeric + numeric
df_numerized = df.copy()
for col_name in df_numerized:
    if(df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes

correlation_matrix = df_numerized.corr()

sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm')
plt.title('Correlation Matrix for Numerized Movie Features')
plt.xlabel('Movie Features')
plt.ylabel('Movie Features')
plt.show()



