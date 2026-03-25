import { useState, useEffect, useRef } from 'react'
import axios from 'axios'
import { VegaEmbed } from 'react-vega'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import remarkBreaks from 'remark-breaks'
import { Settings, Trash2, SendHorizonal, Database, Share, Sparkles, LayoutDashboard, Bot, User } from 'lucide-react'

// Typing Indicator Component
const TypingIndicator = () => (
  <div className="flex items-center space-x-1 py-1">
    <div className="typing-dot w-2 h-2 bg-slate-400 rounded-full"></div>
    <div className="typing-dot w-2 h-2 bg-slate-400 rounded-full"></div>
    <div className="typing-dot w-2 h-2 bg-slate-400 rounded-full"></div>
  </div>
)

const decodeValue = (val) => {
  if (typeof val === 'string' && val.includes('%')) {
    try { 
      return decodeURIComponent(val).replace(/\^/g, ' '); 
    } catch(e) { return val; }
  }
  return val;
}

const formatCellValue = (key, val) => {
  if (val === null || val === undefined) return '-';
  
  const lowerKey = key.toLowerCase();
  const isTimeKey = lowerKey.includes('_at') || lowerKey.includes('time') || lowerKey.includes('date');
  
  if (isTimeKey) {
    let d;
    if (typeof val === 'number') {
       // Assume seconds if < 100 billion (e.g. up to year 5100)
       const ms = val < 100000000000 ? val * 1000 : val;
       d = new Date(ms);
    } else if (typeof val === 'string') {
       d = new Date(val);
    }
    
    // Check if valid date
    if (d && !isNaN(d.getTime())) {
      return d.toLocaleString('en-US', { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit', hour12: true });
    }
  }
  
  return String(decodeValue(val));
}

function App() {
  const [messages, setMessages] = useState([])
  
  const [role, setRole] = useState('internal')
  const [merchantIdsStr, setMerchantIdsStr] = useState('1, 2')
  
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)
  
  const chatEndRef = useRef(null)

  const merchantInsights = [
    "Top 5 selling items", 
    "All cancelled orders", 
    "Total revenue today", 
    "Lowest performing items", 
    "Average order value"
  ]
  const internalInsights = [
    "Top 5 earning merchants", 
    "Order cancellation rate", 
    "Most popular menu items", 
    "Total platform revenue this week", 
    "Bottom 10 merchants by sales"
  ]
  const insights = role === 'merchant' ? merchantInsights : internalInsights;

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, loading])

  // Clear chat when context changes
  useEffect(() => {
    setMessages([])
  }, [role, merchantIdsStr])

  const parseMerchantIds = (str) => {
    return str.split(',').map(s => parseInt(s.trim())).filter(n => !isNaN(n))
  }

  const sendMessage = async (textOverride = null) => {
    const textToSend = textOverride || input
    if (!textToSend.trim() || loading) return
    
    const userMsg = { role: 'user', content: textToSend }
    const currentMessages = [...messages, userMsg]
    setMessages(currentMessages)
    if (!textOverride) setInput('')
    setLoading(true)

    const historyToSend = currentMessages.slice(-6, -1).map(m => ({
      role: m.role,
      content: m.content || m.summary || ""
    }))
    
    try {
      const res = await axios.post('/text-to-sql/', {
        question: textToSend,
        role: role,
        merchant_ids: role === 'merchant' ? parseMerchantIds(merchantIdsStr) : [],
        chat_history: historyToSend
      })
      
      const data = res.data
      const hasValidChart = data.chart_spec && Object.keys(data.chart_spec).length > 0;
      
      setMessages(prev => [...prev, { 
        role: 'assistant', 
        summary: data.summary || "Okay, I processed your request.",
        chart_spec: hasValidChart ? data.chart_spec : null,
        rows: data.rows,
        final_sql: data.final_sql
      }])
    } catch (err) {
      setMessages(prev => [...prev, { role: 'assistant', error: err?.response?.data?.detail || err.message }])
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-slate-50 text-slate-800 font-sans">
      
      {/* Sidebar */}
      <div className="w-72 bg-white border-r border-slate-200 flex flex-col shadow-sm z-10 hidden md:flex shrink-0">
        <div className="p-6 border-b border-slate-100 flex items-center gap-3">
          <div className="bg-blue-600 p-2 rounded-lg text-white">
            <LayoutDashboard size={20} />
          </div>
          <h1 className="text-lg font-bold text-slate-900 tracking-tight">boons Lens</h1>
        </div>

        <div className="p-6 flex-1 overflow-y-auto">
          <div className="flex items-center gap-2 mb-6 text-slate-800 font-semibold">
            <Settings size={18} />
            <h2>User Context</h2>
          </div>

          <div className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-2">User Role</label>
              <select 
                className="w-full p-2.5 bg-white border border-slate-300 rounded-lg text-sm shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all"
                value={role} 
                onChange={e => setRole(e.target.value)}
              >
                <option value="internal">Internal Team</option>
                <option value="merchant">Merchant Partner</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-600 mb-2">Merchant IDs</label>
              <input 
                className={`w-full p-2.5 border border-slate-300 rounded-lg text-sm shadow-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all ${role === 'internal' ? 'bg-slate-50 text-slate-400 cursor-not-allowed' : 'bg-white'}`}
                value={merchantIdsStr} 
                onChange={e => setMerchantIdsStr(e.target.value)}
                disabled={role === 'internal'}
                placeholder="e.g. 1, 2"
              />
              {role === 'merchant' && <p className="text-xs text-slate-500 mt-2 leading-relaxed">Required to enforce Row-Level Security.</p>}
            </div>
          </div>
        </div>

        <div className="p-4 border-t border-slate-100 bg-white">
          <button 
            onClick={() => setMessages([])}
            className="w-full flex items-center justify-center gap-2 py-2.5 px-4 bg-white border border-slate-200 text-slate-600 rounded-lg hover:bg-slate-50 hover:text-red-600 transition-colors shadow-sm font-medium text-sm"
          >
            <Trash2 size={16} />
            Clear Chat
          </button>
        </div>
      </div>

      {/* Main Workspace (Streamlit Single Column Wide Layout) */}
      <div className="flex-1 flex flex-col relative h-full bg-white overflow-hidden">
        
        {/* Top Navbar */}
        <div className="h-16 border-b border-slate-100 flex items-center justify-between px-6 shrink-0 relative z-10 w-full bg-white/90 backdrop-blur-md">
          <div className="md:hidden font-bold flex items-center gap-2">
            <div className="bg-blue-600 p-1.5 rounded text-white"><LayoutDashboard size={16}/></div> boons Lens
          </div>
          <div className="flex-1"></div>
          <button className="flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900 transition-colors">
            <Share size={16} /> Deploy UI
          </button>
        </div>

        {/* Pinned Quick Insights Bar */}
        <div className="w-full shrink-0 border-b border-slate-100 bg-white/80 backdrop-blur-md z-10">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-3">
            <div className="flex items-center gap-4 flex-wrap">
              <div className="flex items-center gap-2 text-sm font-semibold text-slate-600">
                <Sparkles size={16} className="text-blue-500" /> Quick Insights
              </div>
              <div className="flex flex-wrap gap-2">
                {insights.map(insight => (
                  <button 
                    key={insight}
                    onClick={() => sendMessage(insight)}
                    disabled={loading}
                    className="px-3 py-1.5 bg-slate-50 border border-slate-200 text-slate-700 rounded-lg text-xs hover:border-blue-400 hover:text-blue-700 hover:shadow-sm transition-all font-medium whitespace-nowrap"
                  >
                    {insight}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Scrollable Chat Area */}
        <div className="flex-1 overflow-y-auto pb-40">
          
          <div className="max-w-5xl mx-auto w-full px-4 sm:px-6 lg:px-8 mt-8 flex flex-col gap-8">
            


            {/* Empty State */}
            {messages.length === 0 && !loading && (
              <div className="text-center py-20 text-slate-400">
                <Database size={48} className="mx-auto mb-4 opacity-20" />
                <h2 className="text-xl font-semibold text-slate-600 mb-2">Welcome to boons Lens</h2>
                <p>Ask a question about your data to generate SQL, insights, and charts.</p>
              </div>
            )}

            {/* Chat Messages */}
            {messages.map((m, i) => (
              <div key={i} className="flex gap-4 p-2">
                {/* Avatar */}
                <div className="shrink-0 mt-1">
                  {m.role === 'user' ? (
                    <div className="w-8 h-8 bg-blue-100 text-blue-600 rounded flex items-center justify-center">
                      <User size={18} />
                    </div>
                  ) : (
                    <div className="w-8 h-8 bg-emerald-100 text-emerald-600 rounded flex items-center justify-center shadow-sm">
                      <Bot size={18} />
                    </div>
                  )}
                </div>
                
                {/* Message Body */}
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-semibold text-slate-900 mb-1">
                    {m.role === 'user' ? 'You' : 'boons Lens'}
                  </div>
                  
                  {/* Markdown Text */}
                  <div className="text-slate-800 text-[15px] leading-relaxed prose prose-slate max-w-none">
                    <ReactMarkdown remarkPlugins={[remarkGfm, remarkBreaks]}>{m.content || m.summary}</ReactMarkdown>
                    {m.error && <p className="text-red-500 font-medium">{m.error}</p>}
                  </div>

                  {/* Inline Chart (If generated) */}
                  {m.chart_spec && (
                    <div className="mt-6 border border-slate-200 rounded-xl p-6 bg-white shadow-sm overflow-x-auto w-full">
                      <VegaEmbed spec={{...m.chart_spec, data: { values: m.rows }, width: 'container'}} actions={{export: true, source: false, compiled: false, editor: false}} />
                    </div>
                  )}

                  {/* Inline Table (If generated and no chart explicitly overwrote it) */}
                  {m.rows && m.rows.length > 0 && !m.chart_spec && (() => {
                     // Check if SQL query used UNION ALL to output categorized metrics
                     const groupKey = Object.keys(m.rows[0]).find(k => {
                        const n = k.toLowerCase().trim();
                        return ['category', 'type', 'group', 'segment', 'tier', 'class', 'metric'].includes(n) || n.includes('category') || n.includes('type');
                     });
                     
                     if (groupKey) {
                        const groups = {};
                        m.rows.forEach(r => {
                          const groupName = r[groupKey] || 'Other Data';
                          if (!groups[groupName]) groups[groupName] = [];
                          // Omit the category column from the display for a cleaner table
                          const { [groupKey]: omit, ...rest } = r;
                          groups[groupName].push(rest);
                        });
                        
                        return (
                          <div className="mt-6 flex flex-col gap-6">
                            {Object.entries(groups).map(([groupName, groupRows]) => (
                               <div key={groupName} className="border border-slate-200 rounded-xl overflow-hidden bg-white shadow-sm w-full overflow-x-auto">
                                 <div className="bg-slate-50 px-4 py-3 border-b border-slate-200 font-semibold text-slate-800">
                                   {groupName}
                                 </div>
                                 <table className="w-full text-left border-collapse text-sm">
                                   <thead>
                                     <tr>
                                       {Object.keys(groupRows[0] || {}).map(k => (
                                         <th key={k} className="p-3 font-semibold text-slate-500 uppercase tracking-wider whitespace-nowrap bg-white border-b border-slate-100">
                                           {k.replace(/_/g, ' ')}
                                         </th>
                                       ))}
                                     </tr>
                                   </thead>
                                   <tbody className="divide-y divide-slate-100">
                                     {groupRows.map((row, idx) => (
                                       <tr key={idx} className="hover:bg-slate-50/50">
                                         {Object.entries(row).map(([cellKey, val], vIdx) => (
                                           <td key={vIdx} className="p-3 text-slate-700 whitespace-nowrap">
                                             {formatCellValue(cellKey, val)}
                                           </td>
                                         ))}
                                       </tr>
                                     ))}
                                   </tbody>
                                 </table>
                               </div>
                            ))}
                          </div>
                        );
                     }
                     
                     // Standard un-grouped table
                     return (
                        <div className="mt-6 border border-slate-200 rounded-xl overflow-hidden bg-white shadow-sm w-full overflow-x-auto">
                          <table className="w-full text-left border-collapse text-sm">
                            <thead>
                              <tr className="bg-slate-50 border-b border-slate-200">
                                {Object.keys(m.rows[0] || {}).map(k => (
                                  <th key={k} className="p-3 font-semibold text-slate-600 uppercase tracking-wider whitespace-nowrap">
                                    {k.replace(/_/g, ' ')}
                                  </th>
                                ))}
                              </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                              {m.rows.map((row, idx) => (
                                <tr key={idx} className="hover:bg-slate-50/50">
                                  {Object.entries(row).map(([cellKey, val], vIdx) => (
                                    <td key={vIdx} className="p-3 text-slate-700 whitespace-nowrap">
                                      {formatCellValue(cellKey, val)}
                                    </td>
                                  ))}
                                </tr>
                              ))}
                            </tbody>
                          </table>
                        </div>
                     );
                  })()} 

                </div>
              </div>
            ))}

            {/* Loading / Typing State */}
            {loading && (
              <div className="flex gap-4 p-2">
                <div className="shrink-0 mt-1">
                  <div className="w-8 h-8 bg-emerald-100 text-emerald-600 rounded flex items-center justify-center shadow-sm">
                    <Bot size={18} className="animate-pulse" />
                  </div>
                </div>
                <div className="flex-regular pt-2">
                   <TypingIndicator />
                </div>
              </div>
            )}
            
            <div ref={chatEndRef} className="h-4" />
          </div>
        </div>

        {/* Global Chat Input (Fixed Bottom like Streamlit) */}
        <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-white via-white to-transparent pt-10 pb-6 px-4 md:px-8">
          <div className="max-w-4xl mx-auto relative flex items-center shadow-lg shadow-slate-200/60 rounded-full bg-white border border-slate-200">
            <input 
              className="w-full py-4 pl-6 pr-16 bg-transparent border-none outline-none focus:ring-0 text-[15px]"
              value={input} 
              onChange={e => setInput(e.target.value)} 
              onKeyDown={e => e.key === 'Enter' && sendMessage()}
              placeholder="Ask a question about your data..."
              disabled={loading}
            />
            <button 
              className={`absolute right-2 p-2 rounded-full flex items-center justify-center transition-all ${input.trim() && !loading ? 'bg-blue-600 text-white hover:bg-blue-700' : 'bg-slate-100 text-slate-400 cursor-not-allowed'}`}
              onClick={() => sendMessage()}
              disabled={!input.trim() || loading}
            >
              <SendHorizonal size={18} />
            </button>
          </div>
          <p className="text-center text-xs text-slate-400 mt-4">AI can make mistakes. Verify important queries.</p>
        </div>

      </div>
    </div>
  )
}
export default App
