-- which shopping source do the top 28.7% prefer?
with cte as (
	select CustomerKey 
	from custval
	where rnk <= 5152
)
select Shopping_Source, count(*) CntShopping_Source
from overalsales c
join cte on cte.CustomerKey = c.CustomerKey
group by 1
order by 2 desc;

Shopping_Source		CntShopping_Source
Facebook				4312
Affiliate				4245
Organic					4216
Google					4152
Twitter					4151
=========================================
Top 80%				   21635 out of 56046 orders

🔍 Key Insights
Variation (3.88% difference from highest to lowest) is not significant.

📊 Insights:
Facebook is the leading shopping source by a small margin, indicating strong performance in social media-driven traffic and conversions.
Affiliate and Organic sources are nearly tied with Facebook, suggesting that both partnership marketing and organic (SEO-driven) 
traffic are highly effective channels.
Google and Twitter are close behind, with only a slight difference in counts compared to the top sources, highlighting a 
well-diversified acquisition strategy across paid search and social media.

Strategic Implications:-
Balanced Channel Performance: The counts for all five sources are very close, indicating no single channel is disproportionately 
dominant or underperforming. This diversification can help mitigate risk if one channel’s performance drops.
High Social Media Impact: With Facebook and Twitter both in the top five, social media marketing is a major driver for 
customer acquisition. Consider investing further in content and paid campaigns on these platforms to maintain or grow share.
Affiliate Marketing Strength: The strong performance of affiliate channels suggests that partnerships and influencer 
collaborations are yielding results. Continuing to optimize and expand these relationships could drive further growth.
Organic and Google Traffic: High counts from organic and Google sources show effective SEO and paid search strategies. 
Regularly monitor and refine these campaigns to sustain visibility and conversion rates.

Recommendations:
Continue Diversification: Maintain a balanced approach to channel investment, as all sources are performing similarly well.
Deepen Social and Affiliate Engagement: Explore new content formats, influencer partnerships, and targeted campaigns on 
Facebook and Twitter.
Optimize SEO and SEM: Regularly audit and enhance organic and paid search strategies to stay competitive in these channels.
Monitor Channel-Specific Metrics: Track conversion rates, average order value, and customer lifetime value by source to 
identify opportunities for optimization beyond just acquisition volume.
“Monitoring your sales and key metrics is critical in ecommerce... These business metrics help you gauge popular products, 
how often certain products are purchased, if there are any issues in the checkout process that are keeping new customers 
from converting, and so much more.”
Summary:
All five shopping sources are strong contributors to customer acquisition. The data suggests a healthy, diversified 
marketing mix, with particular strengths in social media, affiliate marketing, and search. Continued optimization and 
investment across these channels will help sustain and grow ecommerce performance.

-- Demographic distribution for top 29.5% customers (If the data of all sales customer was available in the customers table then its useful.)
select 
	CustomerKey, concat(FirstName, " ", LastName) as Name, MaritalStatus, Gender, Annual_Income$, TotalChildren, EducationLevel, HomeOwner
from customers
right join custval using(CustomerKey)
where rnk <= 5152
order by rnk;

