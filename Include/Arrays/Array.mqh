//+------------------------------------------------------------------+
//|                                                        Array.mqh |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
//+------------------------------------------------------------------+
//| Class CArray                                                     |
//| Purpose: Base class of dynamic arrays.                           |
//|          Derives from class CObject.                             |
//+------------------------------------------------------------------+
class CArray : public CObject
  {
protected:
   int               m_step_resize;      // increment size of the array
   int               m_data_total;       // number of elements
   int               m_data_max;         // maximmum size of the array without memory reallocation
   int               m_sort_mode;        // mode of array sorting

public:
                     CArray(void);
                    ~CArray(void);
   //--- methods of access to protected data
   int               Step(void) const { return(m_step_resize); }
   bool              Step(const int step);
   int               Total(void) const { return(m_data_total); }
   int               Available(void) const { return(m_data_max-m_data_total); }
   int               Max(void) const { return(m_data_max); }
   bool              IsSorted(const int mode=0) const { return(m_sort_mode==mode); }
   int               SortMode(void) const { return(m_sort_mode); }
   //--- cleaning method
   void              Clear(void) { m_data_total=0; }
   //--- methods for working with files
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   //--- sorting method
   void              Sort(const int mode=0);

protected:
   virtual void      QuickSort(int beg,int end,const int mode=0) { m_sort_mode=-1; }
   //--- templates for methods of searching for minimum and maximum
   template<typename T>
   int               Minimum(const T &data[],const int start,const int count) const;
   template<typename T>
   int               Maximum(const T &data[],const int start,const int count) const;
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CArray::CArray(void) : m_step_resize(16),
                       m_data_total(0),
                       m_data_max(0),
                       m_sort_mode(-1)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CArray::~CArray(void)
  {
  }
//+------------------------------------------------------------------+
//| Method Set for variable m_step_resize                            |
//+------------------------------------------------------------------+
bool CArray::Step(const int step)
  {
//--- check
   if(step>0)
     {
      m_step_resize=step;
      return(true);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Sorting an array in ascending order                              |
//+------------------------------------------------------------------+
void CArray::Sort(const int mode)
  {
//--- check
   if(IsSorted(mode))
      return;
   m_sort_mode=mode;
   if(m_data_total<=1)
      return;
//--- sort
   QuickSort(0,m_data_total-1,mode);
  }
//+------------------------------------------------------------------+
//| Writing header of array to file                                  |
//+------------------------------------------------------------------+
bool CArray::Save(const int file_handle)
  {
//--- check handle
   if(file_handle!=INVALID_HANDLE)
     {
      //--- write start marker - 0xFFFFFFFFFFFFFFFF
      if(FileWriteLong(file_handle,-1)==sizeof(long))
        {
         //--- write array type
         if(FileWriteInteger(file_handle,Type(),INT_VALUE)==INT_VALUE)
            return(true);
        }
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Reading header of array from file                                |
//+------------------------------------------------------------------+
bool CArray::Load(const int file_handle)
  {
//--- check handle
   if(file_handle!=INVALID_HANDLE)
     {
      //--- read and check start marker - 0xFFFFFFFFFFFFFFFF
      if(FileReadLong(file_handle)==-1)
        {
         //--- read and check array type
         if(FileReadInteger(file_handle,INT_VALUE)==Type())
            return(true);
        }
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Find minimum of array                                            |
//+------------------------------------------------------------------+
template<typename T>
int CArray::Minimum(const T &data[],const int start,const int count) const
  {
   int real_count;
//--- check for empty array
   if(m_data_total<1)
     {
      SetUserError(ERR_USER_ARRAY_IS_EMPTY);
      return(-1);
     }
   //--- check for start is out of range
   if(start<0 || start>=m_data_total)
     {
      SetUserError(ERR_USER_ITEM_NOT_FOUND);
      return(-1);
     }
//--- compute count of elements
   real_count=(count==WHOLE_ARRAY || start+count>m_data_total) ? m_data_total-start : count;
#ifdef __MQL5__
   return(ArrayMinimum(data,start,real_count));
#else
   return(ArrayMinimum(data,real_count,start));
#endif
  }
//+------------------------------------------------------------------+
//| Find maximum of array                                            |
//+------------------------------------------------------------------+
template<typename T>
int CArray::Maximum(const T &data[],const int start,const int count) const
  {
   int real_count;
//--- check for empty array
   if(m_data_total<1)
     {
      SetUserError(ERR_USER_ARRAY_IS_EMPTY);
      return(-1);
     }
   //--- check for start is out of range
   if(start<0 || start>=m_data_total)
     {
      SetUserError(ERR_USER_ITEM_NOT_FOUND);
      return(-1);
     }
//--- compute count of elements
   real_count=(count==WHOLE_ARRAY || start+count>m_data_total) ? m_data_total-start : count;
#ifdef __MQL5__
   return(ArrayMaximum(data,start,real_count));
#else
   return(ArrayMaximum(data,real_count,start));
#endif
  }
//+------------------------------------------------------------------+
