# Example Prompts Library

The following are example prompts you can use with DataDoe MCP for Amazon.com seller operations.  
You can copy-paste or adapt these as needed in your workflows.

> [!NOTE]  
> Some example prompts contain parameters in curly braces (e.g., `{{seller_name}}`).  
> When using these prompts, always replace parameters with your actual account name, ASIN, SKU, or other relevant value.  
> For example, if your seller account is "Acme Brands", update `{{seller_name}}` to "Acme Brands".

---

## 1) Show registered sellers

Use when: you want a quick list of seller accounts connected to Amazon.com.

```text
Show my sellers registered on Amazon.com
```

## 2) List active listings

Use when: you need a current snapshot of products live on Amazon.

```text
List all my active Amazon product listings
```

## 3) Get inventory by SKU

Use when: you want stock visibility for replenishment planning.

```text
Show current inventory levels for all my SKUs
```

## 4) Download last month's sales report

Use when: you need historical sales data for monthly review.

```text
Download last month's Amazon sales report
```

## 5) Summarize weekly PPC ad spend

Use when: you want a weekly performance view of paid campaigns.

```text
Prepare me report which includes Top 5 PPC Child ASINs by spend for the last month for {{seller_name}} seller.
```

## 6) Show last 7 days sales by seller

Use when: you want a quick weekly sales snapshot for a specific seller account.

```text
Show my sales for last 7 days for {{seller_name}} seller
```

## 7) List last month's cancelled orders by seller

Use when: you need a cancellation-focused order export for operational review.

```text
Prepare list of orders for {{seller_name}} seller for last month which order status is 'Cancelled'. Provide Amazon Order ID, Order Status, Date, Fulfillment Channel and City Destination.
```

## 8) Generate Modern Seller Dashboard Visualization

Use when: You want to create or visualize a clean and modern dashboard for a specific Amazon seller (e.g., for reporting, analysis, executive review, or performance monitoring) with mock or real data.

```text
Act as an expert Frontend Developer. Your task is to build a responsive, production-ready Dashboard for a seller named "Delto UK".

**Project Setup & Execution:**
1. Create a new directory named `./dashboard` in the current project workspace.
2. Inside the `./dashboard` directory, create a simple web application using three standard files: `index.html`, `styles.css`, and `script.js`.
3. Link `styles.css` and `script.js` inside `index.html` so the dashboard can be instantly run and viewed using the Live Server plugin.
4. Import the necessary libraries via CDN in the HTML file (e.g., Chart.js for data visualization and Lucide for icons).

**Scope Constraint:**
- **Strict Adherence:** Build exactly what is requested below. Do NOT add any additional features, pages, buttons, or UI elements that are not explicitly described in this prompt.

**Tech Stack:**
- Core: HTML5, Vanilla JavaScript
- Styling: Vanilla CSS3 (write custom styles and add smooth loading/hover animations)
- Visualization: Chart.js (via CDN)
- Icons: Lucide (via CDN)

**Data Requirements (DataDoe MCP):**
- **DO NOT MOCK DATA.** You must use the available DataDoe MCP tools to fetch the required data for the current period (March 2026, 31 days) and the comparison period (February 2026).
- Implement proper asynchronous data fetching inside `script.js`.
- Include graceful HTML/CSS loading states (e.g., skeleton loaders or spinners) and DOM error handling while the data is being retrieved via MCP tools.

**Layout & Styling Guidelines (in `styles.css`):**
- Aesthetic: Clean, modern, minimalist (similar to Stripe or Vercel UI).
- Backgrounds: Use a subtle light gray for the main page body (e.g., `#f9fafb`) and pure white (`#ffffff`) for the component cards.
- Edges: Use soft borders and shadows (e.g., `box-shadow: 0 1px 3px rgba(0,0,0,0.05)`, border radius `12px`, and a subtle border like `1px solid #f3f4f6`).

**Feature 1: KPIs Grid**
- Layout: CSS Grid (1 column on mobile, 2 on tablet, 4 on desktop).
- Metrics required: Total Sales (£), Total Units Sold, Total Orders, Total ACOS (%).
- Card UI Requirements:
  - A relevant, subtle Lucide icon in the top right (muted color).
  - Metric Name: Muted text, small, uppercase tracking (e.g., font-size 12px, color `#6b7280`, letter-spacing `0.05em`).
  - Metric Value: Large, bold, dark text.
  - Period Comparison: Show the percentage change compared to February 2026.
  - Color-coding Logic: Green text for positive trends, Red text for negative trends.
  - IMPORTANT EXCEPTION: For ACOS, lower is better. A decrease must be Green, and an increase must be Red.

**Feature 2: Day-by-Day Line Chart**
- Placement: A large, responsive card directly below the KPI grid.
- Title: "Financial Overview: March 2026" (styled cleanly at the top of the card).
- Chart Specifications (using Chart.js):
  - X-axis: Dates from March 1 to March 31.
  - Y-axis: Currency amount (£).
  - Line 1 (Total Profit): Smooth curve (`tension: 0.4`), primary brand color (bold blue or emerald green).
  - Line 2 (Ads Costs): Smooth curve (`tension: 0.4`), secondary muted color (orange or red).
  - Interactivity: Enable Chart.js tooltips to display exact values for both lines on hover.
  - Context: Include a legend at the top right or bottom of the chart.
```

## 9) Generate Weekly PDF Business Report

Use when: you want to automatically generate a weekly PDF Business Report for a specific seller account, including finances, risk/exceptions, and recommendations, in a presentation-ready document.

// Fill all curly brace parameters with concrete values before running:

- `{{seller_name}}` – Seller name (e.g., "Delto UK")
- `{{date_start}}` – Start date of reporting period (e.g., 09.04.2026)
- `{{date_end}}` – End date of reporting period (e.g., 16.04.2026)
- `{{output_pdf_name}}` – PDF filename to save (e.g., DeltoUK_WeeklyReport.pdf)

```text
Generate a script to automatically create a weekly PDF Business Report for a `{{seller_name}}` seller.

**Tech Stack & Requirements:**

- Use the `react-pdf` library for PDF creation.
- Data must include: daily revenue, ad spend, refunds, and flagged system events.
- Date range is from `{{date_start}}` to `{{date_end}}`.

**Document Layout & Styling:**

1. **Header & Meta Information**

   - Title: "`{{seller_name}}`: Weekly Performance & Security Report"
   - Date Range: `{{date_start}}` – `{{date_end}}`
   - Insert a subtle dividing line below the header.

2. **Financial Summary (Profits & Losses)**

   - Display a summary block showing: **Total Revenue**, **Total Costs** (Ads + Fees), and **Net Profit** for the week.
   - Add a concise, generated summary (1–2 sentences) explaining the week's financial trend versus a typical week.

3. **Suspicious Activity & Exceptions**

   - Define "suspicious activity" as: either an unusually high return rate on a specific day or a spike in declined transactions (mock the data accordingly).
   - List incidents as bullet points. If none, output: “All systems normal. No anomalous activity detected.”

4. **Strategic Recommendations**
   - Based on the above mock data, provide **exactly three actionable recommendations** (to increase sales or reduce costs).
   - Each should be a numbered list: start with a bold title for the action, plus a brief supporting explanation.
     Example: `1. **Optimize Ad Spend on Weekends:** Data shows...`

**Execution:**

- The script must compile without errors and save the output PDF to the `./pdfReport` directory within the agent workspace, using the file name `{{output_pdf_name}}`.
```
