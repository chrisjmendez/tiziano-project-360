package org.tizianoproject.model
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.tizianoproject.model.vo.Author;
	import org.tizianoproject.model.vo.Story;
	
	public interface IModel extends IEventDispatcher
	{
		function load( path:String ):void
			
		//StudentView + MentorView
		function getAuthorsByType( authorType:String, authorName:String=null ):Array
			
		//Author
		function getAuthorByName( authorName:String ):Author
		function getAuthorTypeByName( authorName:String ):String
			
		//Articles
		function getOtherArticlesByAuthorName( authorName:String, storyID:Number ):Array
		function getAllArticlesByAuthorName( authorName:String ):Array			
			
		function getArticleByArticleID( uniqueID:Number ):Story
	}
}